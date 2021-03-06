//
//  BreakItViewController.swift
//  BreakIt
//
//  Created by yangyang on 5/12/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class BreakItViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    @IBOutlet weak var gameView: BezierPathsView!
    
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var score: Int = 0 {
        didSet {
            let text = NSLocalizedString("Score: %d", comment: "score label")
            scoreLabel.text = String.localizedStringWithFormat(text, score)
        }
    }
    
    // MARK: static constants for break it game
    struct ConstantsForBreakItGame {
        static let BrickCollisionNotification = "BreakItGameBrickCollision"
        static let BallHitBottomNotification = "BreakItGameBallHitBottom"
        
        static let LeftBoundaryName = "BreakItGameLeftBoundaryName"
        static let RightBoundaryName = "BreakItGameRightBoundargName"
        static let TopBoundaryName = "BreakItGameTopBoundaryName"
        static let BottomBoundaryName = "BreakItGameBottomBoundaryName"
        
        static let BlankHeight = CGFloat(20.0)
        
        static let NumberOfMaxBricksRow = 4
        static let NumberOfBricksPerRow = 5
        static let BrickPathName = "BreakItGameBrickPathName"
        static let BrickFillColor = UIColor.purpleColor()
        static let BrickStrokeColor = UIColor.purpleColor()
        static let BrickSpecialType = [1:UIColor.redColor(), 2:UIColor.greenColor()]
        
        static let BallRadius = CGFloat(15.0)
        static let BallPathName = "BreakItGameBallPathName"
        static let BallDefaultVelocity = 500.0
        static let BallFillColor = UIColor.blueColor()
        static let BallSpecialFillColor = UIColor.brownColor()
        
        static let PaddleWidth = CGFloat(80.0)
        static let PaddleHeight = CGFloat(20.0)
        static let PaddlePathName = "BreakItGamePaddlePathName"
        static let PaddleFillColor = UIColor.blackColor()
        static let PaddleStrokeColor = UIColor.blackColor()
    }
    
    // MARK: init view controller
    lazy var animator: UIDynamicAnimator = {
       let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
        
    }()
    
    let breakItBehavior = BreakItBehavior()
    
    private var brickCollsionObserver: NSObjectProtocol?
    private var ballHitBottomObserver: NSObjectProtocol?
    
    var isGameOver: Bool = false {
        didSet{
            if self.isGameOver {
                Score.createInManagedObjectContext(self.managedObjectContext!, id: NSDate(), value: self.score)
            }
        }
    }
    
    var isGamePause: Bool = false {
        didSet {
            if self.isGamePause && !isGameOver {
                self.hintLabel.hidden = false
                self.hintLabel.text = NSLocalizedString("Continue?", comment: "continue hint of the game after ")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameView.backgroundColor = UIColor.clearColor()
        animator.addBehavior(breakItBehavior)
        
        startCollisionEventObserver()
        
        startGame()
        
        pauseGame()
        self.hintLabel.text = NSLocalizedString("Start Game", comment: "Start game")
    }
    
    // MARK: restart game using the user default settings
    // start break it game using the user defaults
    func startGame()
    {
        score = 0
        gameView.superview?.backgroundColor = UIColor.whiteColor()
        
        hintLabel.hidden = true
        isGameOver = false
        isGamePause = false
        
        var defaults = NSUserDefaults.standardUserDefaults()
        var ballNumbers = defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey)
        if ballNumbers == 0 {
            ballNumbers = 1
            defaults.setInteger(ballNumbers, forKey: SettingViewController.BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey)
        }
        
        var brickRows = defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.RowOfBricksKey)
        if brickRows == 0 {
            brickRows = 1
            defaults.setInteger(brickRows, forKey: SettingViewController.BreakItGameUserDefaultsKey.RowOfBricksKey)
        }
        
        var bounciness = defaults.doubleForKey(SettingViewController.BreakItGameUserDefaultsKey.BouncinessKey)
        
        if bounciness < 1.0 {
            bounciness = 1.0
            defaults.setDouble(bounciness, forKey: SettingViewController.BreakItGameUserDefaultsKey.BouncinessKey)
        } else if bounciness > 1.1 {
            bounciness = 1.1
            defaults.setDouble(bounciness, forKey: SettingViewController.BreakItGameUserDefaultsKey.BouncinessKey)
        }
        
        breakItBehavior.setBounciness(bounciness)
        
        isPaddingOvel = defaults.boolForKey(SettingViewController.BreakItGameUserDefaultsKey.PaddingStateKey)
        
        
        initBall(ballNumbers)
        initPaddle()
        initBrick(brickRows)
    }
    
    class Ball {
        var name: String
        
        var view: UIView
        var velocity: CGPoint
        
        init(view: UIView, name: String)
        {
            self.name = name
            self.view = view
            var angle = (Double(arc4random() % UINT32_MAX) - 0.5) * M_PI_2
            self.velocity = CGPoint(x: sin(angle)*ConstantsForBreakItGame.BallDefaultVelocity, y: cos(angle)*ConstantsForBreakItGame.BallDefaultVelocity)
        }
    }
    
    var balls: [Ball] = [Ball]()
    
    func initBall(numOfBalls: Int)
    {
        if !balls.isEmpty {
            for ball in balls {
                breakItBehavior.removeBall(ball.view, named: ball.name)
                ball.view.removeFromSuperview()
            }
            balls.removeAll(keepCapacity: false)
        }
        
        let ballSize = CGSize(width: ConstantsForBreakItGame.BallRadius*2, height: ConstantsForBreakItGame.BallRadius*2)
        for i in 0..<numOfBalls {
            let ballOrigin = CGPoint(x: gameView.frame.midX - CGFloat(numOfBalls-1+2*i)*ConstantsForBreakItGame.BallRadius , y: gameView.frame.height * CGFloat(1.0 / 2.0))
            var ballFrame = CGRect(origin: ballOrigin, size: ballSize)
            let ballView = UIView(frame: ballFrame)
            
            ballView.layer.cornerRadius = ConstantsForBreakItGame.BallRadius
            ballView.clipsToBounds = true
            ballView.layer.borderColor = ConstantsForBreakItGame.BallFillColor.CGColor
            ballView.layer.borderWidth = 1
            ballView.layer.backgroundColor = ConstantsForBreakItGame.BallFillColor.CGColor
            
            let name = ConstantsForBreakItGame.BallPathName + String(i)
            let ball = Ball(view: ballView, name: name)
            balls.append(ball)
            breakItBehavior.addBall(ballView, named: name)
            breakItBehavior.setLinearVelocityForBall(ballView, velocity: ball.velocity)
        }
    }
    
    var isPaddingOvel: Bool? = false
    var paddleOriginPoint: CGPoint? {
        didSet {
            let rect = CGRect(origin: self.paddleOriginPoint!, size: CGSize(width: ConstantsForBreakItGame.PaddleWidth, height: ConstantsForBreakItGame.PaddleHeight))
            
            var path: UIBezierPath? = nil;
            
            if isPaddingOvel! {
                path = UIBezierPath(ovalInRect: rect)
            } else {
                path = UIBezierPath(rect: rect)
            }
            
            breakItBehavior.setPaddle(path!, named: ConstantsForBreakItGame.PaddlePathName)
            gameView.setPath(path, fillColor: ConstantsForBreakItGame.PaddleFillColor, strokeColor: ConstantsForBreakItGame.PaddleStrokeColor, name: ConstantsForBreakItGame.PaddlePathName)
        }
    }
    
    func initPaddle()
    {
        paddleOriginPoint = CGPointZero
    }
    
    class Brick {
        var path: UIBezierPath
        var view: UIView
        var name: String
        var row: Int
        var column: Int
        var fillColor: UIColor
        var strokeColor: UIColor
        
        var type: Int = 0
        
        init(path: UIBezierPath, view: UIView, name: String, row: Int, column: Int, fillColor: UIColor, strokeColor: UIColor){
            self.path = path
            self.view = view
            self.name = name
            self.row = row
            self.column = column
            self.fillColor = fillColor
            self.strokeColor = strokeColor
        }
    }
    
    var brickViews: [Brick] = [Brick]()
    
    var brickSize: CGSize {
        get{
            let brickWidth = gameView.bounds.size.width / CGFloat(ConstantsForBreakItGame.NumberOfBricksPerRow * 2)
            let brickHeight = gameView.bounds.size.height / CGFloat(ConstantsForBreakItGame.NumberOfMaxBricksRow * 10)
            return CGSize(width: brickWidth, height: brickHeight)
        }
    
    }
    
    var brickBlank: CGSize {
        get {
            return CGSize(width: (gameView.bounds.size.width - brickSize.width * CGFloat(ConstantsForBreakItGame.NumberOfBricksPerRow)) / (CGFloat(ConstantsForBreakItGame.NumberOfBricksPerRow) + 1), height: brickSize.height)
        }
    }
    
    func initBrick(rowOfBricks: Int)
    {
        let size = brickSize
        let blank = brickBlank
        
        if !brickViews.isEmpty {
            for brick in brickViews {
                brick.view.removeFromSuperview()
                breakItBehavior.removeBrick(brick.name)
            }
            brickViews.removeAll(keepCapacity: false)
        }
        
        for i in 1...rowOfBricks
        {
            for j in 1...ConstantsForBreakItGame.NumberOfBricksPerRow
            {
                let brickRect = CGRect(origin: CGPoint(x: CGFloat(j)*blank.width + CGFloat(j-1)*size.width, y: CGFloat(i)*blank.height + CGFloat(i-1)*size.height), size: size)
                let path = UIBezierPath(rect: brickRect)
                let view = UIView(frame: brickRect)
                view.backgroundColor = ConstantsForBreakItGame.BrickFillColor
                gameView.addSubview(view)
                
                let name = ConstantsForBreakItGame.BrickPathName + ("\(i)_\(j)")
                
                breakItBehavior.addBrick(path, named: name)
                
                let brick = Brick(path: path, view: view, name: name, row: i, column: j, fillColor: ConstantsForBreakItGame.BrickFillColor, strokeColor: ConstantsForBreakItGame.BrickStrokeColor)
                
                let brickType = Int(arc4random() % 100)
                
                // 10% percent of type 1, 10% percent of type 2
                if brickType <= 10 {
                    brick.type = 1
                    view.backgroundColor = ConstantsForBreakItGame.BrickSpecialType[1]
                    brick.fillColor = ConstantsForBreakItGame.BrickSpecialType[1]!
                    brick.strokeColor = ConstantsForBreakItGame.BrickSpecialType[1]!
                } else if brickType <= 20 {
                    brick.type = 2
                    view.backgroundColor = ConstantsForBreakItGame.BrickSpecialType[2]
                    brick.fillColor = ConstantsForBreakItGame.BrickSpecialType[2]!
                    brick.strokeColor = ConstantsForBreakItGame.BrickSpecialType[2]!
                }
                
                brickViews.append(brick)
            }
            
        }
    }
    
    // MARK: status cahnged methods
    var isPaddleTabbed = false
    
    @IBAction func drag(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            detectIsPaddleTabbed(gesturePoint)
        case .Changed:
            if isPaddleTabbed {
                if let originPoint = paddleOriginPoint{
                    var x = originPoint.x + sender.translationInView(gameView).x
                    if x < 0 {
                        x = 0
                    } else if x >= gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth {
                        x = gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth
                    }
                    paddleOriginPoint = CGPoint(x: x,
                        y: originPoint.y)
                }
            }
            sender.setTranslation(CGPointZero, inView: gameView)
        case .Ended:
            isPaddleTabbed = false
        default: break
        }
    }
    
    func detectIsPaddleTabbed(point: CGPoint)
    {
        if let originPoint = paddleOriginPoint {
            let paddleRect = CGRect(origin: originPoint, size: CGSize(width: ConstantsForBreakItGame.PaddleWidth, height: ConstantsForBreakItGame.PaddleHeight))
            isPaddleTabbed = paddleRect.contains(point)
        }
    }
    
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        if isGameOver {
            startGame()
        } else if isGamePause {
            isGamePause = false
            hintLabel.hidden = true
            setBallStatus()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setGameBoundries()
        setPaddleStatus()
        setBricksStatus()
    }
    
    func setGameBoundries()
    {
        let margin = CGFloat(1.0)
        let leftTopPoint = CGPoint(x: gameView.bounds.minX + margin, y: gameView.bounds.minY + margin)
        let rightTopPoint = CGPoint(x: gameView.bounds.maxX - margin, y: gameView.bounds.minY + margin)
        let leftBottomPoint = CGPoint(x: gameView.bounds.minX + margin, y: gameView.bounds.maxY - margin)
        let rightBottomPoint = CGPoint(x: gameView.bounds.maxX - margin, y: gameView.bounds.maxY - margin)
        breakItBehavior.setBoundary(ConstantsForBreakItGame.LeftBoundaryName, fromPoint: leftTopPoint, toPoint: leftBottomPoint)
        breakItBehavior.setBoundary(ConstantsForBreakItGame.RightBoundaryName, fromPoint: rightTopPoint, toPoint: rightBottomPoint)
        breakItBehavior.setBoundary(ConstantsForBreakItGame.TopBoundaryName, fromPoint: leftTopPoint, toPoint: rightTopPoint)
        breakItBehavior.setBoundary(ConstantsForBreakItGame.BottomBoundaryName, fromPoint: leftBottomPoint, toPoint: rightBottomPoint)
    }
    
    func setBallStatus()
    {
        for ball in balls {
            breakItBehavior.setLinearVelocityForBall(ball.view, velocity: ball.velocity)
        }
    }
    
    // Paddle is the BezierPath
    func setPaddleStatus()
    {
        if paddleOriginPoint?.y != gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BlankHeight
        {
            paddleOriginPoint = CGPoint(x: (gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth) / CGFloat(2.0)  , y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BlankHeight)
        }
        
    }
    
    // Brick is the UIView
    func setBricksStatus()
    {
        let size = brickSize
        let blank = brickBlank
        
        for brick in brickViews {
            let brickRect = CGRect(origin: CGPoint(x: CGFloat(brick.column)*blank.width + CGFloat(brick.column-1)*size.width, y: CGFloat(brick.row)*blank.height + CGFloat(brick.row-1)*size.height + ConstantsForBreakItGame.BlankHeight), size: size)
            
            brick.view.frame = brickRect
            gameView.addSubview(brick.view)

            let path = UIBezierPath(rect: brickRect)
            brick.path = path
            
            breakItBehavior.addBrick(path, named: brick.name)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey(SettingViewController.BreakItGameUserDefaultsKey.IsSettingEdited)
        {
            currentGameResetAlert()
        }
        
        defaults.setBool(false, forKey: SettingViewController.BreakItGameUserDefaultsKey.IsSettingEdited)
    }
    
    func currentGameResetAlert()
    {
        var alert = UIAlertController(title: NSLocalizedString("Restart game", comment: "alert title of resrat the game"), message: NSLocalizedString("Your game setting has been changed, want to restart game now?", comment: "context of restart game alert controller") , preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancle", comment: "title of cancle button in restart alert controller") , style: UIAlertActionStyle.Cancel, handler: { [unowned self] action  -> Void in
            self.isGamePause = true
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Restart", comment: "title of restart button in restart alert controller"), style: UIAlertActionStyle.Default, handler: { [unowned self] action -> Void in
            // restart the game using the new user game setting
            self.startGame()
        }))
        view.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    // The method will save the state for current in the future
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
        pauseGame()
    }
    
    func pauseGame(){
        if !isGamePause {
            for ball in balls {
                ball.velocity = breakItBehavior.clearLinearVelocityForBall(ball.view)
                
                if isSlow {
                    ball.velocity.x = ball.velocity.x *  CGFloat(2)
                    ball.velocity.y = ball.velocity.y *  CGFloat(2)
                }
                
            }
        }
        
        isGamePause = true
    }
    
    // MARK: handle collision events
    var collidePoint: CGPoint = CGPointZero
    
    func startCollisionEventObserver()
    {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        
        brickCollsionObserver = center.addObserverForName(ConstantsForBreakItGame.BrickCollisionNotification, object: nil, queue: queue) {
            [unowned self] notification in
            if let name = notification.userInfo?[ConstantsForBreakItGame.BrickPathName] as? String {
                let ballName = notification.userInfo?[ConstantsForBreakItGame.BallPathName] as! String
                self.collidePoint = CGPoint(x: notification.userInfo?["x"] as! CGFloat, y: notification.userInfo?["y"] as! CGFloat)
                self.removeBrickWithName(name, collideBallName: ballName)
            }
        }
        
        ballHitBottomObserver = center.addObserverForName(ConstantsForBreakItGame.BallHitBottomNotification, object: nil, queue: queue) {
            [unowned self] notification in
            self.finishGame()
        }
        
    }
    
    func stopCollisionEventObserver()
    {
        if let observer = brickCollsionObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        if let observer = ballHitBottomObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func removeBrickWithName(name: String, collideBallName: String)
    {
        
        for i in 0..<brickViews.count {
            if brickViews[i].name == name {
                
                breakItBehavior.removeBrick(name)
                let brick = brickViews.removeAtIndex(i) as Brick
                score += balls.count
                
                if brick.type != 0 {
                    
                    // special brick type 1, add balls
                    if brick.type == 1 {
                        score += 1
                        addSpecialBall(collideBallName)
                    }
                    
                    // special brick type 2, slow down game speed
                    if brick.type == 2 {
                        slowDownGameSpeed()
                    }

                }
                
                
                UIView.transitionWithView(gameView, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {brick.view.alpha = 0.0}) {
                    if $0 {
                        brick.view.removeFromSuperview()
                    }
                }
                
                break
            }
        }
        
        if brickViews.isEmpty {
            hintLabel.hidden = false
            hintLabel.text = NSLocalizedString("Congratulations!!!", comment: "Hint when user break all the bricks")
            
            for ball in balls {
                breakItBehavior.clearLinearVelocityForBall(ball.view)
            }
            
            score *= 2
            isGameOver = true
        }
    }
    
    func addSpecialBall(ballName: String)
    {
        var hitBall: Ball!
        
        for ball in balls {
            if ball.name == ballName
            {
                hitBall = ball
                break
            }
        }
        
        if let ball = hitBall {
            ball.velocity = breakItBehavior.linearVelocityForBall(ball.view)
            
            let ballOrigin = CGPoint(x: ball.view.frame.origin.x + ball.view.frame.width * (ball.velocity.x > 0 ? 1 : -1),
                                      y: ball.view.frame.origin.y + ball.view.frame.height * (ball.velocity.y > 0 ? 1 : -1))
            
            var ballFrame = CGRect(origin: ballOrigin, size: ball.view.frame.size)
            let ballView = UIView(frame: ballFrame)
            
            ballView.layer.cornerRadius = ConstantsForBreakItGame.BallRadius
            ballView.clipsToBounds = true
            ballView.layer.borderColor = ConstantsForBreakItGame.BallSpecialFillColor.CGColor
            ballView.layer.borderWidth = 1
            ballView.layer.backgroundColor = ConstantsForBreakItGame.BallSpecialFillColor.CGColor
            
            let name = ConstantsForBreakItGame.BallPathName + String(balls.count)
            let b = Ball(view: ballView, name: name)
            balls.append(b)
            breakItBehavior.addBall(ballView, named: name)
            breakItBehavior.setLinearVelocityForBall(ballView, velocity: CGPoint(x: -ball.velocity.x, y: -ball.velocity.y))
        }
    }
    
    // slow the velocity of the balls & set background to be gray
    
    let animateDuration = 2.0
    
    var isSlow = false
    
    func slowDownGameSpeed()
    {
        if !isSlow {
            for ball in balls {
                let v = breakItBehavior.linearVelocityForBall(ball.view)
                breakItBehavior.setLinearVelocityForBall(ball.view, velocity: CGPoint(x: v.x / CGFloat(2), y: v.y / CGFloat(2)))
            }
            
            UIView.animateWithDuration( animateDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { [unowned self] in
                    self.gameView.superview?.backgroundColor = UIColor.grayColor()
                }) { (value: Bool) -> Void in
            }
            UIView.animateWithDuration(animateDuration,
                delay: animateDuration,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { [unowned self] in
                    self.gameView.superview?.backgroundColor = UIColor.whiteColor()
                }) { [unowned self] (value: Bool) -> Void in
                    
                    for ball in self.balls {
                        let v = self.breakItBehavior.linearVelocityForBall(ball.view)
                        self.breakItBehavior.setLinearVelocityForBall(ball.view, velocity: CGPoint(x: v.x * CGFloat(2), y: v.y * CGFloat(2)))
                    }
                    
                    self.isSlow = false
            }
        }
        
        isSlow = true

    }
    
    func finishGame()
    {
        hintLabel.hidden = false
        hintLabel.text = NSLocalizedString("Oops!", comment: "Hint when user ball hit the bootom")
        
        for ball in balls {
            breakItBehavior.clearLinearVelocityForBall(ball.view)
        }
        isGameOver = true
    }
    
    // remove observer
    deinit
    {
        stopCollisionEventObserver()
    }
    
}
