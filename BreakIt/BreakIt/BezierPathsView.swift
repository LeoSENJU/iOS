//
//  BezierPathsView.swift
//  BreakIt
//  The class is used to set the bezier path of the view
//  and draw them
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    private var bezierPaths = [String : UIBezierPath]()
    
    func setPath(path: UIBezierPath?, name: String)
    {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths
        {
            path.stroke()
        }
    }
    
}
