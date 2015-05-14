//
//  BreakItBehavior.swift
//  BreakIt
//  The class for managing the behaviors of the UI components
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class BreakItBehavior: UIDynamicBehavior {
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollider
    }()
    
    override init() {
        super.init()
        addChildBehavior(collider)
    }
    
    func addBrick(path: UIBezierPath, named name:String)
    {
        
    }
    
    func removeBrick(name: String)
    {
        
    }
    
    func addBehaviorItem(item: UIView)
    {
        dynamicAnimator?.referenceView?.addSubview(item)
        collider.addItem(item)
    }
    
    func removeBehaviorItem(item: UIView)
    {
        collider.removeItem(item)
    }
}
