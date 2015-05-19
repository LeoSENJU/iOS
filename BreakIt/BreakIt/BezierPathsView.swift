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
    
    private class BreakItGamePaths
    {
        var path: UIBezierPath?
        var fillColor: UIColor?
        var strokeColor: UIColor?
        
        init(path: UIBezierPath?, fillColor: UIColor?, strokeColor: UIColor?)
        {
            self.path = path
            self.fillColor = fillColor
            self.strokeColor = strokeColor
        }
        
        func draw()
        {
            fillColor?.setFill()
            strokeColor?.setStroke()
            path?.fill()
            path?.stroke()
        }
    }

    private var bezierPaths = [BreakItGamePaths]()
    
    func setPath(path: UIBezierPath?, fillColor: UIColor?, strokeColor: UIColor?)
    {
        bezierPaths.append(BreakItGamePaths(path: path, fillColor: fillColor, strokeColor: strokeColor))
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for path in bezierPaths
        {
            path.draw()
        }
    }
    
}
