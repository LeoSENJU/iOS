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
        static let PaddleWidth = CGFloat(5.0)
        static let PaddelHeight = CGFloat(1.0)
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
    
    // Set the position of bricks, paddle and ball when game start and restart from pause
    // For the time being, just implement the start
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addBall()
        addPaddle()
        addBricks()
        
        //println("View did layout");
    }
    
    var ballView: UIView?
    
    // Ball is the UIView
    func addBall()
    {
        if ballView == nil
        {
            var frame = CGRect(origin: CGPointZero, size: CGSize(width: ConstantsForBreakItGame.BallRadius*2, height: ConstantsForBreakItGame.BallRadius*2))
            
            ballView = UIView(frame: frame)
            ballView!.layer.cornerRadius = ConstantsForBreakItGame.BallRadius
            ballView!.clipsToBounds = true
            
            ballView!.layer.borderColor = UIColor.blueColor().CGColor
            ballView!.layer.borderWidth = 1
            breakItBehavior.addBall(ballView!)
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
