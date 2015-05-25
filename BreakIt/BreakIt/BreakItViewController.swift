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
        
        static let BallRadius = CGFloat(15.0)
        static let BallPathName = "BreakItGameBallPathName"
        static let BallDefaultVelocity = 500.0
        static let BallFillColor = UIColor.blueColor()
        
        static let PaddleWidth = CGFloat(100.0)
        static let PaddleHeight = CGFloat(15.0)
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
    
    var isGameOver: Bool = false
    var isGamePause: Bool = false {
        didSet {
            if self.isGamePause && !isGameOver {
                self.hintLabel.hidden = false
                self.hintLabel.text = "Continue?"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakItBehavior)
        
        startCollisionEvenObserver()
        
        startGame()
    }
    
    // MARK: restart game using the user default settings
    // start break it game using the user defaults
    func startGame()
    {
        hintLabel.hidden = true
        isGameOver = false
        isGamePause = false
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        initBall(defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey))
        initPaddle()
        initBrick(defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.RowOfBricksKey))
    }
    
    class Ball {
        var view: UIView
        var velocity: CGPoint
        
        init(view: UIView)
        {
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
                breakItBehavior.removeBall(ball.view)
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
            
            let ball = Ball(view: ballView)
            balls.append(ball)
            breakItBehavior.addBall(ballView)
            breakItBehavior.setLinearVelocityForBall(ballView, velocity: ball.velocity)
        }
    }
    
    var paddleOriginPoint: CGPoint? {
        didSet {
            let path = UIBezierPath(rect: CGRect(origin: self.paddleOriginPoint!, size: CGSize(width: ConstantsForBreakItGame.PaddleWidth, height: ConstantsForBreakItGame.PaddleHeight)))
            
            breakItBehavior.setPaddle(path, named: ConstantsForBreakItGame.PaddlePathName)
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
                brickViews.append(Brick(path: path, view: view, name: name, row: i, column: j, fillColor: ConstantsForBreakItGame.BrickFillColor, strokeColor: ConstantsForBreakItGame.BrickStrokeColor))
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
    
    // Brick is the UIview
    func setBricksStatus()
    {
        let size = brickSize
        let blank = brickBlank
        
        for brick in brickViews {
            let brickRect = CGRect(origin: CGPoint(x: CGFloat(brick.column)*blank.width + CGFloat(brick.column-1)*size.width, y: CGFloat(brick.row)*blank.height + CGFloat(brick.row-1)*size.height), size: size)
            
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
        var alert = UIAlertController(title: "Restart game", message: "Your game setting has been changed, want to restart game now?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: { [unowned self] action  -> Void in
            self.isGamePause = true
        }))
        
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { [unowned self] action -> Void in
            // restart the game using the new user game setting
            self.startGame()
        }))
        view.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    // The method will save the state for current in the future
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
        if !isGamePause {
            for ball in balls {
                ball.velocity = breakItBehavior.clearLinearVelocityForBall(ball.view)
            }
        }
        
        isGamePause = true
    }
    
    // MARK: handle collision events
    func startCollisionEvenObserver()
    {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        
        brickCollsionObserver = center.addObserverForName(ConstantsForBreakItGame.BrickCollisionNotification, object: nil, queue: queue) {
            [unowned self] notification in
            if let name = notification.userInfo?[ConstantsForBreakItGame.BrickPathName] as? String {
                self.removeBrickWithName(name)
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
    
    func removeBrickWithName(name: String)
    {
        
        for i in 0..<brickViews.count {
            if brickViews[i].name == name {
                breakItBehavior.removeBrick(name)
                let brick = brickViews.removeAtIndex(i) as Brick
                
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
            hintLabel.text = "Congratulations!!!"
            
            for ball in balls {
                breakItBehavior.clearLinearVelocityForBall(ball.view)
            }
            
            isGameOver = true
        }
    }
    
    func finishGame()
    {
        hintLabel.hidden = false
        hintLabel.text = "Oops!"
        
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
