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
    
    var brickSize: CGSize {
        let brickWidth = gameView.bounds.size.width / CGFloat(ConstantsForBreakItGame.NumberOfBricksPerRow * 2)
        let brickHeight = gameView.bounds.size.height / CGFloat(ConstantsForBreakItGame.NumberOfMaxBricksRow * 3)
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakItBehavior)
        restartGame()
    }
    
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
            gameView.setPath(path, fillColor: ConstantsForBreakItGame.PaddleFillColor, strokeColor: ConstantsForBreakItGame.PaddleStrokeColor)
        }
    }
    
    func initPaddle()
    {
        
    }
    
    func initBrick(rowOfBricks: Int)
    {
        
    }
    
    // MARK: status cahnged methods
    var isPaddleTabbed = false
    var lastPaddleOriginLocation: CGPoint?
    
    @IBAction func drag(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            detectIsPaddleTabbed(gesturePoint)
        case .Changed:
            if isPaddleTabbed {
                if let originPoint = lastPaddleOriginLocation {
                    var x = originPoint.x + sender.translationInView(gameView).x
                    if x < 0 {
                        x = 0
                    } else if x >= gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth {
                        x = gameView.bounds.size.width - ConstantsForBreakItGame.PaddleWidth
                    }
                    paddleOriginPoint = CGPoint(x: x,
                        y: originPoint.y)
                    sender
                }
                //originPoint.x += sender.translationInView(self.gameView).x
                
            }
        case .Ended:
            isPaddleTabbed = false
        default: break
        }
    }
    
    func detectIsPaddleTabbed(point: CGPoint)
    {
        if let originPoint = paddleOriginPoint {
            let paddleRect = CGRect(origin: originPoint, size: CGSize(width: ConstantsForBreakItGame.PaddleWidth, height: ConstantsForBreakItGame.PaddleHeight))
            lastPaddleOriginLocation = originPoint
            isPaddleTabbed = paddleRect.contains(point)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setBallStatus()
        setPaddleStatus()
        setBricksStatus()
    }
    
    // Ball is the UIView
    func setBallStatus()
    {
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
        
    }
    
    // TODO
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        println(defaults.integerForKey(SettingViewController.BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey))
        
        
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
        //println("View will disappear");
    }
}
