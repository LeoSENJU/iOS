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
    
    // MARK: init view controller
    lazy var animator: UIDynamicAnimator = {
       let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    let breakItBehavior = BreakItBehavior()
    
    struct ConstantsForBreakItGame {
        static let NumberOfMaxBricksRow = 4
        static let NumberOfBricksPerRow = 5
        static let BlankHeight = CGFloat(10.0)
        
        static let BallRadius = CGFloat(10.0)
        static let BallPathName = "BreakItGameBallPathName"
        static let BallInitVelocity = CGPoint(x: 0.0, y: -500.0)
        
        static let PaddleWidth = CGFloat(50.0)
        static let PaddleHeight = CGFloat(10.0)
        static let PaddlePathName = "BreakItGamePaddlePathName"
        static let PaddleFillColor = UIColor.blackColor()
        static let PaddleStrokeColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakItBehavior)
        
        restartGame()
    }
    
    // MARK: restart game using the user default settings
    // restart break it game using the user defaults
    func restartGame()
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
        var view: UIView
        var row: Int
        var column: Int
        
        init(view: UIView, row: Int, column: Int){
            self.view = view
            self.row = row
            self.column = column
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
                var brickFrame = CGRect(origin: CGPoint(x: CGFloat(j)*blank.width + CGFloat(j-1)*size.width, y: CGFloat(i)*blank.height + CGFloat(i-1)*size.height), size: size)
                let brickView = UIView(frame: brickFrame)
                brickViews.append(Brick(view: brickView, row: i, column: j))
                
                brickView.backgroundColor = UIColor.purpleColor()
                breakItBehavior.addBrick(brickView)
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
        
        setBallStatus()
        setPaddleStatus()
        setBricksStatus()
        //println("didlayout subviews")
    }
    
    // Ball is the UIView
    func setBallStatus()
    {
        let size = brickSize
        let blank = brickBlank
        
        if let view = ballView {
            breakItBehavior.removeBall(view)
            view.frame.origin = CGPoint(x: gameView.bounds.size.width / CGFloat(2.0) - ConstantsForBreakItGame.BallRadius, y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BallRadius*2 - ConstantsForBreakItGame.BlankHeight)
            breakItBehavior.addBall(view)
            //breakItBehavior.setLinearVelocityForBall(ConstantsForBreakItGame.BallInitVelocity, ball: view)
        }
    }
    
    // Paddle is the BezierPath
    func setPaddleStatus()
    {
        paddleOriginPoint = CGPoint(x: (gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth) / CGFloat(2.0)  , y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BlankHeight)
    }
    
    // Brick is the UIview
    func setBricksStatus()
    {
        let size = brickSize
        let blank = brickBlank
        
        for brick in brickViews {
            brick.view.frame = CGRect(origin: CGPoint(x: CGFloat(brick.column)*blank.width + CGFloat(brick.column-1)*size.width, y: CGFloat(brick.row)*blank.height + CGFloat(brick.row-1)*size.height), size: size)
            breakItBehavior.addBrick(brick.view)
        }
        
    }
    
    // TODO
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        var alert = UIAlertController(title: "Restart game", message: "Your game setting has been changed, want to restart game now ?", preferredStyle: UIAlertControllerStyle.Alert)
        
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
}
