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
    
    // MARK: static constants for break it game
    struct ConstantsForBreakItGame {
        static let BrickCollisionNotification = "BreakItGameBrickCollision"
        static let BallHitBottomNotification = "BreakItGameBallHitBottom"
        
        static let LeftBoundaryName = "BreakItGameLeftBoundaryName"
        static let RightBoundaryName = "BreakItGameRightBoundargName"
        static let TopBoundaryName = "BreakItGameTopBoundaryName"
        static let BottomBoundaryName = "BreakItGameBottomBoundaryName"
        
        static let BlankHeight = CGFloat(10.0)
        
        static let NumberOfMaxBricksRow = 4
        static let NumberOfBricksPerRow = 5
        static let BrickPathName = "BreakItGameBrickPathName"
        static let BrickFillColor = UIColor.purpleColor()
        static let BrickStrokeColor = UIColor.purpleColor()
        
        static let BallRadius = CGFloat(10.0)
        static let BallPathName = "BreakItGameBallPathName"
        static let BallInitVelocity = CGPoint(x: 0.0, y: -500.0)
        
        static let PaddleWidth = CGFloat(50.0)
        static let PaddleHeight = CGFloat(10.0)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakItBehavior)
        
        startCollisionEvenObserver()
        
        startGame()
    }
    
    // MARK: restart game using the user default settings
    // restart break it game using the user defaults
    func startGame()
    {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        initBall(defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey))
        initPaddle()
        initBrick(defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.RowOfBricksKey))
    }
    
    var ballView: UIView?
    var ballLinearVelocity: CGPoint = CGPointZero
    
    // TODO to be modified from single ball to the number of balls to be spicified
    func initBall(numOfBalls: Int)
    {
        let ballOrigin = CGPointZero
        var ballFrame = CGRect(origin: ballOrigin, size: CGSize(width: ConstantsForBreakItGame.BallRadius*2, height: ConstantsForBreakItGame.BallRadius*2))
        
        ballView = UIView(frame: ballFrame)
        let view = ballView!
        
        view.layer.cornerRadius = ConstantsForBreakItGame.BallRadius
        view.clipsToBounds = true
        
        view.layer.borderColor = UIColor.blueColor().CGColor
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.blueColor()
        
        ballLinearVelocity = ConstantsForBreakItGame.BallInitVelocity
        breakItBehavior.setLinearVelocityForBall(ballLinearVelocity, ball: ballView!)
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
        var name: String
        var row: Int
        var column: Int
        var fillColor: UIColor
        var strokeColor: UIColor
        
        init(path: UIBezierPath, name: String, row: Int, column: Int, fillColor: UIColor, strokeColor: UIColor){
            self.path = path
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
        
        for i in 1...rowOfBricks
        {
            for j in 1...ConstantsForBreakItGame.NumberOfBricksPerRow
            {
                let path = UIBezierPath(rect: CGRect(origin: CGPoint(x: CGFloat(j)*blank.width + CGFloat(j-1)*size.width, y: CGFloat(i)*blank.height + CGFloat(i-1)*size.height), size: size))
                let name = ConstantsForBreakItGame.BrickPathName + ("\(i)_\(j)")
                let fillColor = ConstantsForBreakItGame.BrickFillColor
                let strokeColor = ConstantsForBreakItGame.BrickStrokeColor
                
                brickViews.append(Brick(path: path, name: name, row: i, column: j, fillColor: fillColor, strokeColor: strokeColor))
                
                breakItBehavior.addBrick(path, named: name)
                gameView.setPath(path, fillColor: fillColor, strokeColor: strokeColor, name: name)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setGameBoundries()
        setBallStatus()
        setPaddleStatus()
        setBricksStatus()
        //println("didlayout subviews")
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
        let size = brickSize
        let blank = brickBlank
        
        if let view = ballView {
            breakItBehavior.removeBall(view)
            view.frame.origin = CGPoint(x: gameView.bounds.size.width / CGFloat(2.0) - ConstantsForBreakItGame.BallRadius, y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BallRadius*2 - ConstantsForBreakItGame.BlankHeight)
            breakItBehavior.addBall(view)
            breakItBehavior.setLinearVelocityForBall(ConstantsForBreakItGame.BallInitVelocity, ball: view)
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
            let path = UIBezierPath(rect: CGRect(origin: CGPoint(x: CGFloat(brick.column)*blank.width + CGFloat(brick.column-1)*size.width, y: CGFloat(brick.row)*blank.height + CGFloat(brick.row-1)*size.height), size: size))
            
            brick.path = path
            breakItBehavior.addBrick(path, named: brick.name)
            gameView.setPath(path, fillColor: brick.fillColor, strokeColor: brick.strokeColor, name: brick.name)
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
        
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            // do nothing when user choose to cancle restart the game
        }))
        
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // restart the game using the new user game setting
        }))
        view.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    // The method will save the state for current in the future
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
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
        for brick in brickViews {
            if brick.name == name {
                breakItBehavior.removeBrick(name)
                gameView.removePath(name)
                break
            }
        }
    }
    
    func finishGame()
    {
        
    }
    
    // remove observer
    deinit
    {
        stopCollisionEventObserver()
    }
    
}
