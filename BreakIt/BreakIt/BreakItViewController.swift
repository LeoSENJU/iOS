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
    
    lazy var animator: UIDynamicAnimator = {
       let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    let breakItBehavior = BreakItBehavior()
    
    struct ConstantsForBreakItGame {
        static let NumberOfMaxBricksColumn = 4
        static let NumberOfBricksPerRow = 5
        
        static let BallRadius = CGFloat(10.0)
        static let BallPathName = "BreakItGameBallPathName"
        static let BallInitVelocity = CGPoint(x: 0.0, y: -500.0)
        
        static let PaddleWidth = CGFloat(50.0)
        static let PaddleHeight = CGFloat(10.0)
        static let PaddlePathName = "BreakItGamePaddlePathName"
    }
    
    var brickSize: CGSize {
        let brickWidth = gameView.bounds.size.width / CGFloat(ConstantsForBreakItGame.NumberOfBricksPerRow * 2)
        let brickHeight = gameView.bounds.size.height / CGFloat(ConstantsForBreakItGame.NumberOfMaxBricksColumn * 3)
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakItBehavior)
    }
    
    // The method will save the state for current in the future
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        //println("View will disappear");
    }
    
    var ballView: UIView?
    var lastGameViewBoundSize: CGSize = CGSizeZero
    
    // Set the position of bricks, paddle and ball when game start and restart from pause
    // For the time being, just implement the start
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addBall()
        addPaddle()
        addBricks()
        
        //println("View did layout");
    }
    
    // Ball is the UIView
    func addBall()
    {
        if ballView == nil
        {
            let ballOrigin = CGPoint(x: gameView.bounds.size.width / CGFloat(2.0) - ConstantsForBreakItGame.BallRadius, y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BallRadius*2)
            var ballFrame = CGRect(origin: ballOrigin, size: CGSize(width: ConstantsForBreakItGame.BallRadius*2, height: ConstantsForBreakItGame.BallRadius*2))
            
            ballView = UIView(frame: ballFrame)
            let view = ballView!
            
            view.layer.cornerRadius = ConstantsForBreakItGame.BallRadius
            view.clipsToBounds = true
            
            view.layer.borderColor = UIColor.blueColor().CGColor
            view.layer.borderWidth = 1
            view.backgroundColor = UIColor.blueColor()
            breakItBehavior.addBall(view)
            breakItBehavior.setLinearVelocityForBall(ConstantsForBreakItGame.BallInitVelocity, ball: view)
            lastGameViewBoundSize = gameView.bounds.size
        }
        else if lastGameViewBoundSize != gameView.bounds.size
        {
            if let view = ballView {
                breakItBehavior.removeBall(view)
                view.frame.origin = CGPoint(x: gameView.bounds.size.width / CGFloat(2.0) - ConstantsForBreakItGame.BallRadius, y: gameView.bounds.size.height - ConstantsForBreakItGame.PaddleHeight - ConstantsForBreakItGame.BallRadius*2)
                breakItBehavior.addBall(view)
                breakItBehavior.setLinearVelocityForBall(ConstantsForBreakItGame.BallInitVelocity, ball: view)
            }
            
            lastGameViewBoundSize = gameView.bounds.size
        }
        
    }
    
    // Paddle is the BezierPath
    func addPaddle()
    {
        
    }
    
    // Brick is the UIview
    func addBricks()
    {
        
    }
}
