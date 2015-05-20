//
//  BreakItBehavior.swift
//  BreakIt
//  The class for managing the behaviors of the UI components
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class BreakItBehavior: UIDynamicBehavior {
    
    // MARK init dynamic animation behavior
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollider
    }()
    
    lazy var breakItBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBreakItBehavior = UIDynamicItemBehavior()
        lazilyCreatedBreakItBehavior.allowsRotation = false
        lazilyCreatedBreakItBehavior.elasticity = 1.0
        lazilyCreatedBreakItBehavior.friction = 0.0
        lazilyCreatedBreakItBehavior.resistance = 0.0
        return lazilyCreatedBreakItBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(breakItBehavior)
    }
    
    // MARK: Set and remove items
    
    // For the time being ball, paddle and bricks are implemented separated
    func addBall(ball: UIView)
    {
        removeBall(ball)
        addBehaviorItem(ball)
    }
    
    func removeBall(ball: UIView)
    {
        removeBehaviorItem(ball)
    }
    
    func setPaddle(path: UIBezierPath, named name: String)
    {
        collider.removeBoundaryWithIdentifier(name)
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBrick(brick: UIView)
    {
        removeBrick(brick)
        addBehaviorItem(brick)
    }
    
    func removeBrick(brick: UIView)
    {
        removeBehaviorItem(brick)
    }
    
    func addBehaviorItem(item: UIView)
    {
        dynamicAnimator?.referenceView?.addSubview(item)
        collider.addItem(item)
        breakItBehavior.addItem(item)
    }
    
    func removeBehaviorItem(item: UIView)
    {
        collider.removeItem(item)
        breakItBehavior.removeItem(item)
    }
    
    // MARK: set and get ball status
    func linearVelocityForBall(ball: UIDynamicItem) -> CGPoint
    {
        return breakItBehavior.linearVelocityForItem(ball)
    }
    
    func setLinearVelocityForBall(velocity: CGPoint, ball: UIDynamicItem)
    {
        breakItBehavior.addLinearVelocity(velocity, forItem: ball)
    }
    
}
