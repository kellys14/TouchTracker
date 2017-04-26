//
//  DrawView.swift
//  TouchTracker
//
//  Created by Sean Melnick Kelly on 4/10/17.
//  Copyright © 2017 Sean Melnick Kelly. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]() // pg. 323 - Creates dict. containing instances of Line
    var finishedLines = [Line]()
    var selectedLineIndex: Int? { // pg. 337 for variable
        didSet { // pg. 340 for property observer
            // Adds property observer to selectedLineIndex to clear menu if there isn't any lines
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var moveRecognizer: UIPanGestureRecognizer!
    
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
            
            // START CHAPTER 18 SILVER CHALLENGE
            let lineAngle = atan2(line.begin.y - line.end.y, line.begin.x - line.end.x)
            
            if lineAngle >= 0 && lineAngle < 1 {
                UIColor.orange.setStroke()
            } else if lineAngle >= 1 && lineAngle < 2 {
                UIColor.purple.setStroke()
            } else if lineAngle >= 2 && lineAngle <= 3.14 {
                UIColor.darkGray.setStroke()
            } else if lineAngle < 0 && lineAngle >= -1 {
                UIColor.magenta.setStroke()
            } else if lineAngle < -1 && lineAngle >= -2 {
                UIColor.yellow.setStroke()
            } else if lineAngle < -2 && lineAngle >= -3.14 {
                UIColor.cyan.setStroke()
            }
            // END CHAPTER 18 SILVER CHALLENGE
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines { // pg. 326
            stroke(line)
        }
        
        if let index = selectedLineIndex { // pg. 337
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
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
    
    required init?(coder aDecoder: NSCoder) { // Method that initiate UITapGestureRecognizer
        super.init(coder: aDecoder)
        
        // Double tap instaniate for clear screen - pg. 334
        let doubleTapRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true // pg. 335 to prevent red-dot on double tap
        addGestureRecognizer(doubleTapRecognizer)
        
        // Line tap instaniate for line select (for menu) - pg. 336
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        
        // Long press instantiate to be maybe use move line in future - pg. 341
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        // Move recognizer instantiate following a long press - pg. 342
        moveRecognizer = UIPanGestureRecognizer(target: self,
                                                action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self // Sets the DrawView delegate to UIPanGestRecog... - pg. 344
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
        
    }
    
    func doubleTap(_ gestureRecognizer: UITapGestureRecognizer) { // pg. 335 
        // Method thats called double-tap occurs on an instance of DrawView
        print("Recognized a double tap")
        
        selectedLineIndex = nil // To prevent index trap when clearing lines - pg. 338
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Method thats called when line is tapped
        print("Recognized a tap") // pg. 336
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        // Grab the menu controller - pg. 339
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil { // pg. 339 - if else statement
            
            // Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            // Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            // Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    func longPress(_ gestureRecognizer: UIGestureRecognizer) { // pg. 342
        // Method that is called when a long press occurs
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began { // long presses have states(.began,.ended) since its continuous
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
        setNeedsDisplay()
    }
    
    func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) { // pg. 345
        // Method that is called when a pan(drag) occurs
        print("Recognized a pan")
        
        // If a line is selected...
        if let index = selectedLineIndex {
            // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                // Resets translation to zero for next move
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                // Redraw the screen
                setNeedsDisplay()
            }
        } else {
            // If no line is selected, do not do anything
            return
        }
    }
    
    func indexOfLine(at point: CGPoint) -> Int? { // pg. 337
        // Method that returns the index of the Line closest to a given point
        
        // Find a line close to the point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line - stride(from:to:by:) method explained top of pg. 338
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }
        // If nothing is close enough to the tapped pointt, then we did not select a line
        return nil
    }
    
    override var canBecomeFirstResponder: Bool { // pg. 340
        // Allows UIMenuController to become FirstResponder
        return true
    }
    
    func deleteLine(_ sender: UIMenuController) { // pg. 340
        // Remove the selected line from the list of finishedLines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            // Redraw everything
            setNeedsDisplay()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { // pg. 344
        // Delegate used for UIPanGestureRecognizer
        return true
    }
}
