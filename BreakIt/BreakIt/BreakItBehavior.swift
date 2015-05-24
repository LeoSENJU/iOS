//
//  BreakItBehavior.swift
//  BreakIt
//  The class for managing the behaviors of the UI components
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class BreakItBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    // MARK init dynamic animation behavior
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        lazilyCreatedCollider.collisionDelegate = self
        
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
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBrick(path: UIBezierPath, named name: String)
    {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBrick(name: String)
    {
        collider.removeBoundaryWithIdentifier(name)
    }
    // MARK: set boundries
    func setBoundary(name: String, fromPoint: CGPoint, toPoint: CGPoint){
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, fromPoint: fromPoint, toPoint: toPoint)
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
    
    // MARK: private functions to add and remove behavior items
    private func addBehaviorItem(item: UIView)
    {
        dynamicAnimator?.referenceView?.addSubview(item)
        collider.addItem(item)
        breakItBehavior.addItem(item)
    }
    
    private func removeBehaviorItem(item: UIView)
    {
        collider.removeItem(item)
        breakItBehavior.removeItem(item)
    }
    
    // MARK: manage collision behavior between ball/bricks and ball/boundaries
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        //println(identifier)
        let identifieropt: NSCopying? = identifier
        if let name = identifieropt as? String {
            if name.hasPrefix(BreakItViewController.ConstantsForBreakItGame.BrickPathName) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BreakItViewController.ConstantsForBreakItGame.BrickCollisionNotification, object: nil, userInfo: [BreakItViewController.ConstantsForBreakItGame.BrickPathName : name]))
            }
            
            if name == BreakItViewController.ConstantsForBreakItGame.BottomBoundaryName {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BreakItViewController.ConstantsForBreakItGame.BallHitBottomNotification, object: nil))
            }
        }
        
    }
}
