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
    
    // Set the position of bricks, paddle and ball when game start and restart from pause
    // For the time being, just implement the start
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
