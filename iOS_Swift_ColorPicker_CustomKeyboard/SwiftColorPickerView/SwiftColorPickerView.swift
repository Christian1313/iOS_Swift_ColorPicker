//
//  SwiftColorPickerView.swift
//  iOSColorPicker
//
//  Created by Christian Zimmermann on 02.03.15.
//  Copyright (c) 2015 Christian Zimmermann. All rights reserved.
//

// Note: The 'public' infront of the classe and property declaration is needed, 
//       because the ViewController and the View is part of an framework.

import UIKit

public protocol SwiftColorPickerDelegate {
    
    func colorSelectionChanged(selectedColor color: UIColor)
}

public protocol SwiftColorPickerDataSource: class {
    
    func colorForPalletIndex(x: Int, y: Int, numXStripes: Int, numYStripes: Int) -> UIColor
}

/// Color Picker ViewController. Let the user pick a color from a 2D color palette.
/// The delegate (SwiftColorPickerDelegate) will be notified about the color selection change.
/// The user can simply tap a color or pan over the palette. When panning over the palette a round preview
/// view will appear and show the current selected colot.
final public class SwiftColorPickerView: UIView {
    
    /// Delegate of the SwiftColorPickerViewController
    public var delegate: SwiftColorPickerDelegate?
    
    /// Diameter of the circular view, which preview the color selection.
    ///
    /// The preview will appear at the finger tip of the users touch and show the current selected color.
//    public var colorPreviewDiameter:Int = 35 {
//        didSet {
//            setConstraintsForColorPreView()
//        }
//    }
    
    /// Width of the edge around the color palette.
    ///
    /// The border change the color with the selection by the user.
    ///
    /// `Default` is 10
    @IBInspectable public var coloredBorderWidth:Int = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numColorsX * numColorsY`
    ///
    /// `Default` is 10
    @IBInspectable public var numberColorsInXDirection:Int =  10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numColorsX * numColorsY`
    ///
    /// `Default` is 18
    @IBInspectable public var numberColorsInYDirection:Int = 18 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Wether or not the grid between the blocks should be visible.
    ///
    /// `Default` is false
    @IBInspectable public var showGridLines:Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var dataSource: SwiftColorPickerDataSource?
    
    private var selectionViewConstraintX: NSLayoutConstraint = NSLayoutConstraint()
    private var selectionViewConstraintY: NSLayoutConstraint = NSLayoutConstraint()
    
    public override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        let lineColor = UIColor.grayColor()
        let pS = patternSize()
        let w = pS.w
        let h = pS.h
        
        for y in 0..<numberColorsInYDirection {
            
            for x in 0..<numberColorsInXDirection {
                let path = UIBezierPath()
                let start = CGPointMake(CGFloat(x)*w+CGFloat(coloredBorderWidth),CGFloat(y)*h+CGFloat(coloredBorderWidth))
                path.moveToPoint(start);
                path.addLineToPoint(CGPointMake(start.x+w, start.y))
                path.addLineToPoint(CGPointMake(start.x+w, start.y+h))
                path.addLineToPoint(CGPointMake(start.x, start.y+h))
                path.addLineToPoint(start)
                path.lineWidth = 0.25
                colorForRectAt(x,y:y).setFill();
                
                if (showGridLines) {
                    lineColor.setStroke()
                } else {
                    colorForRectAt(x,y:y).setStroke();
                }
                path.fill();
                path.stroke();
            }
        }
    }
    
    private func colorForRectAt(x: Int, y: Int) -> UIColor {
        
        if let ds = dataSource {
            return ds.colorForPalletIndex(x, y: y, numXStripes: numberColorsInXDirection, numYStripes: numberColorsInYDirection)
        } else {
            
            var hue:CGFloat = CGFloat(x) / CGFloat(numberColorsInYDirection)
            var fillColor = UIColor.whiteColor()
            if (y==0)
            {
                if (x==(numberColorsInYDirection-1))
                {
                    hue = 1.0;
                }
                fillColor = UIColor(white: hue, alpha: 1.0);
            }
            else
            {
                let sat:CGFloat = CGFloat(1.0)-CGFloat(y-1) / CGFloat(numberColorsInYDirection)
                fillColor = UIColor(hue: hue, saturation: sat, brightness: 1.0, alpha: 1.0)
            }
            return fillColor
        }
    }
    
    func colorAtPoint(point: CGPoint) -> UIColor {
        
        let pS = patternSize()
        let w = pS.w
        let h = pS.h
        let x = (point.x-CGFloat(coloredBorderWidth))/w
        let y = (point.y-CGFloat(coloredBorderWidth))/h
        
        return colorForRectAt(Int(x), y:Int(y))
    }
    
    private func patternSize() -> (w: CGFloat, h:CGFloat) {
        
        let width = self.bounds.width-CGFloat(2*coloredBorderWidth)
        let height = self.bounds.height-CGFloat(2*coloredBorderWidth)
        
        let w = width/CGFloat(numberColorsInXDirection)
        let h = height/CGFloat(numberColorsInYDirection)
        
        return (w,h)
    }
    
    public override func prepareForInterfaceBuilder() {
        print("Compiled and run for IB")
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            let t = touch
            let point = t.locationInView(self)
            let colorSelected = self.colorAtPoint(point)
            delegate?.colorSelectionChanged(selectedColor: colorSelected)
        }
    }
    
//    func handleGestureRecognizer(recognizer: UIGestureRecognizer) {
//        
//        let point = recognizer.locationInView(self)
//        positionSelectorViewWithPoint(point)
//        
//        if (recognizer.state == UIGestureRecognizerState.Began) {
//            colorSelectionView.alpha = 1.0
//        } else if (recognizer.state == UIGestureRecognizerState.Ended) {
//            startHidingSelectionView()
//        }
//    }

//    private func setConstraintsForColorPreView() {
//        
//        self.removeConstraints(self.constraints)
//        colorSelectionView.layer.cornerRadius = CGFloat(colorPreviewDiameter/2)
//        let views = ["paletteView": self, "selectionView": colorSelectionView]
//        
//        var pad = 10
//        if (colorPreviewDiameter==10) {
//            pad = 13
//        }
//        
//        let metrics = ["diameter" : colorPreviewDiameter, "pad" : pad]
//        
//        let constH2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-pad-[selectionView(diameter)]", options: .DirectionLeadingToTrailing, metrics: metrics, views: views)
//        //var constH2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-pad-[selectionView(diameter)]", options: nil, metrics: metrics, views: views)
//        
//        
//        //var constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-pad-[selectionView(diameter)]", options: nil, metrics: metrics, views: views)
//        let constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-pad-[selectionView(diameter)]", options: .DirectionLeadingToTrailing, metrics: metrics, views: views)
//        self.addConstraints(constH2)
//        self.addConstraints(constV2)
//        
//        for constraint in constH2 {
//            
//            if constraint.constant == CGFloat(pad) {
//                selectionViewConstraintX = constraint
//                break
//            }
//        }
//        
//        for constraint in constV2 {
//            
//            if constraint.constant == CGFloat(pad) {
//                selectionViewConstraintY = constraint
//                break
//            }
//        }
//    }
    
//    private func positionSelectorViewWithPoint(point: CGPoint) {
//        
//        let colorSelected = self.colorAtPoint(point)
//        delegate?.colorSelectionChanged(selectedColor: colorSelected)
//        //self.backgroundColor = UIColor.clearColor()
//        selectionViewConstraintX.constant = (point.x-colorSelectionView.bounds.size.width/2)
//        selectionViewConstraintY.constant = (point.y-1.2*colorSelectionView.bounds.size.height)
//    }
//    
//    private func startHidingSelectionView() {
//        UIView.animateWithDuration(0.5, animations: {
//            self.colorSelectionView.alpha = 0.0
//        })
//    }
}

