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
    func addBall(ball: UIView, named name: String)
    {
        removeBall(ball, named: name)
        addBehaviorItem(ball, named: name)
    }
    
    func removeBall(ball: UIView, named name: String)
    {
        removeBehaviorItem(ball, named: name)
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
    
    // MARK: ball velocity utility functions
    func linearVelocityForBall(ball: UIDynamicItem) -> CGPoint
    {
        return breakItBehavior.linearVelocityForItem(ball)
    }
    
    func setLinearVelocityForBall(ball: UIDynamicItem, velocity: CGPoint)
    {
        clearLinearVelocityForBall(ball)
        addLinearVelocityForBall(ball, velocity: velocity)
    }
    
    func addLinearVelocityForBall(ball: UIDynamicItem, velocity: CGPoint)
    {
        breakItBehavior.addLinearVelocity(velocity, forItem: ball)
    }
    
    func clearLinearVelocityForBall(ball: UIDynamicItem) -> CGPoint
    {
        let velocity = linearVelocityForBall(ball)
        addLinearVelocityForBall(ball ,velocity: CGPoint(x: -velocity.x, y: -velocity.y))
        return velocity
    }
    
    func setBounciness(bouciness: Double) {
        breakItBehavior.elasticity = CGFloat(bouciness)
    }
    
    // MARK: private functions to add and remove behavior items
    
    var itemList = [String: UIDynamicItem]()
    
    private func addBehaviorItem(item: UIView, named name: String)
    {
        dynamicAnimator?.referenceView?.addSubview(item)
        collider.addItem(item)
        breakItBehavior.addItem(item)
        itemList[name] = item
    }
    
    private func removeBehaviorItem(item: UIView, named name: String)
    {
        collider.removeItem(item)
        breakItBehavior.removeItem(item)
        itemList.removeValueForKey(name)
    }
    
    // MARK: manage collision behavior between ball/bricks and ball/boundaries
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        let identifieropt: NSCopying? = identifier
        if let name = identifieropt as? String {
            
            var ballName = ""
            
            for (k, v) in itemList {
                if v === item {
                    ballName = k
                }
            }
            
            if name.hasPrefix(BreakItViewController.ConstantsForBreakItGame.BrickPathName) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BreakItViewController.ConstantsForBreakItGame.BrickCollisionNotification, object: nil, userInfo: [BreakItViewController.ConstantsForBreakItGame.BrickPathName : name, BreakItViewController.ConstantsForBreakItGame.BallPathName : ballName, "x":p.x, "y":p.y]))
            }
            
            if name == BreakItViewController.ConstantsForBreakItGame.BottomBoundaryName {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BreakItViewController.ConstantsForBreakItGame.BallHitBottomNotification, object: nil))
            }
        }
        
    }
}
