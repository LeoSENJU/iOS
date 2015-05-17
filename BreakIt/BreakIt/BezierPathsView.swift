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
    
    private var paddlePath: UIBezierPath?
    private var paddleFillColor: UIColor?
    private var paddleStrokeColor: UIColor?
    
    
    func setPaddle(path: UIBezierPath?, fillColor: UIColor?, strokColor: UIColor?)
    {
        paddlePath = path
        paddleFillColor = fillColor
        paddleStrokeColor = strokColor
        setNeedsDisplay()
    }
    
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
        
        drawPaddle()
    }
    
    func drawPaddle()
    {
        paddleFillColor?.setFill()
        paddleStrokeColor?.setStroke()
        paddlePath?.fill()
        paddlePath?.stroke()
    }
    
}
