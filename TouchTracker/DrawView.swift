//
//  DrawView.swift
//  TouchTracker
//
//  Created by Sean Melnick Kelly on 4/10/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLines = [NSValue:Line]() // pg. 323 - Creates dict. containing instances of Line
    var finishedLines = [Line]()
    
    // @IBInstpectable - pg. 328
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        finishedLineColor.setStroke()
        for line in finishedLines {
            stroke(line)
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines { // pg. 326
            stroke(line)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Log statement to see the order of the events
        print(#function) // pg. 324
        
        for touch in touches { // pg. 324 - Adds lines currently being drawn to this dictionary
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        // Flags the view to be redrawn at the end of the run loop
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Log statement to see the order of events
        print(#function)
        
        for touch in touches { // pg. 325
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Log statement to see the order of events
        print(#function)
        
        for touch in touches { // pg. 326
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { // pg. 327
        // Log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
}
