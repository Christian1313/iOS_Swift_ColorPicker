//
//  SwiftColorPickerViewController.swift
//  iOSColorPicker
//
//  Created by Christian Zimmermann on 02.03.15.
//  Copyright (c) 2015 Christian Zimmermann. All rights reserved.
//

// Note: The 'public' infront of the classe and property declaration is needed,
//       because the ViewController and the View is part of an framework.

import UIKit

public protocol SwiftColorPickerDelegate
{
    func colorSelectionChanged(selectedColor color: UIColor)
}

public protocol SwiftColorPickerDataSource: class
{
    func colorForPalletIndex(x: Int, y: Int, numXStripes: Int, numYStripes: Int) -> UIColor
}

/// Color Picker ViewController. Let the user pick a color from a 2D color palette.
/// The delegate (SwiftColorPickerDelegate) will be notified about the color selection change.
/// The user can simply tap a color or pan over the palette. When panning over the palette a round preview
/// view will appear and show the current selected colot.
final public class SwiftColorPickerViewController: UIViewController
{
    /// Delegate of the SwiftColorPickerViewController
    public var delegate: SwiftColorPickerDelegate?
    
    /// Data Source of the SwiftColorPickerViewController
    public weak var dataSource: SwiftColorPickerDataSource? {
        didSet {
            colorPaletteView.viewDataSource = dataSource
        }
    }
    
    /// Width of the edge around the color palette.
    ///
    /// The border change the color with the selection by the user.
    ///
    /// Default is 10
    public var coloredBorderWidth:Int = 10 {
        didSet {
            colorPaletteView.coloredBorderWidth = coloredBorderWidth
        }
    }
    
    /// Diameter of the circular view, which preview the color selection.
    ///
    /// The preview will appear at the finger tip of the users touch and show the current selected color.
    public var colorPreviewDiameter:Int = 35 {
        didSet {
            setConstraintsForColorPreView()
        }
    }
    
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numberColorsInXDirection * numberColorsInYDirection`
    public var numberColorsInXDirection: Int = 10 {
        didSet {
            colorPaletteView.numColorsX = numberColorsInXDirection
        }
    }
    
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numberColorsInXDirection * numberColorsInYDirection`
    public var numberColorsInYDirection: Int = 18 {
        didSet {
            colorPaletteView.numColorsY = numberColorsInYDirection
        }
    }
    
    private var colorPaletteView: SwiftColorView = SwiftColorView() // is the self.view property
    private var colorSelectionView: UIView = UIView()
    
    private var selectionViewConstraintX: NSLayoutConstraint = NSLayoutConstraint()
    private var selectionViewConstraintY: NSLayoutConstraint = NSLayoutConstraint()
    
    
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func loadView()
    {
        super.loadView()
        if ( !(self.view is SwiftColorView) ) // used if the view controller ist instanciated without interface builder
        {
            let s = colorPaletteView
            s.translatesAutoresizingMaskIntoConstraints = false
            s.contentMode = UIViewContentMode.Redraw
            s.userInteractionEnabled = true
            self.view = s
        }
        else // used if in intervacebuilder the view property is set to the SwiftColorView
        {
            colorPaletteView = self.view as! SwiftColorView
        }
        coloredBorderWidth = colorPaletteView.coloredBorderWidth
        numberColorsInXDirection = colorPaletteView.numColorsX
        numberColorsInYDirection = colorPaletteView.numColorsY
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // needed when using auto layout
        //colorSelectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        colorSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // add subviews
        colorPaletteView.addSubview(colorSelectionView)
        // set autolayout constraints
        setConstraintsForColorPreView()
        
        // setup preview
        colorSelectionView.layer.masksToBounds = true
        colorSelectionView.layer.borderWidth = 0.5
        colorSelectionView.layer.borderColor = UIColor.grayColor().CGColor
        colorSelectionView.alpha = 0.0
        
        
        // adding gesture regocnizer
        let tapGr = UITapGestureRecognizer(target: self, action: "handleGestureRecognizer:")
        let panGr = UIPanGestureRecognizer(target: self, action: "handleGestureRecognizer:")
        panGr.maximumNumberOfTouches = 1
        colorPaletteView.addGestureRecognizer(tapGr)
        colorPaletteView.addGestureRecognizer(panGr)
        colorPaletteView.viewDataSource = dataSource
    }
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first
        {
            let t = touch
            let point = t.locationInView(colorPaletteView)
            positionSelectorViewWithPoint(point)
            colorSelectionView.alpha = 1.0
        }
    }
    
    
    
    func handleGestureRecognizer(recognizer: UIGestureRecognizer)
    {
        let point = recognizer.locationInView(self.colorPaletteView)
        positionSelectorViewWithPoint(point)
        if (recognizer.state == UIGestureRecognizerState.Began)
        {
            colorSelectionView.alpha = 1.0
        }
        else if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            startHidingSelectionView()
        }
    }
    
    private func setConstraintsForColorPreView()
    {
        colorPaletteView.removeConstraints(colorPaletteView.constraints)
        colorSelectionView.layer.cornerRadius = CGFloat(colorPreviewDiameter/2)
        let views = ["paletteView": self.colorPaletteView, "selectionView": colorSelectionView]
        
        var pad = 10
        if (colorPreviewDiameter==10)
        {
            pad = 13
        }
        
        let metrics = ["diameter" : colorPreviewDiameter, "pad" : pad]
        
        let constH2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-pad-[selectionView(diameter)]", options: .DirectionLeadingToTrailing, metrics: metrics, views: views)
        //var constH2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-pad-[selectionView(diameter)]", options: nil, metrics: metrics, views: views)
        
        
        //var constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-pad-[selectionView(diameter)]", options: nil, metrics: metrics, views: views)
        let constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-pad-[selectionView(diameter)]", options: .DirectionLeadingToTrailing, metrics: metrics, views: views)
        colorPaletteView.addConstraints(constH2)
        colorPaletteView.addConstraints(constV2)
        
        for constraint in constH2
        {
            if constraint.constant == CGFloat(pad)
            {
                selectionViewConstraintX = constraint
                break
            }
        }
        for constraint in constV2
        {
            if constraint.constant == CGFloat(pad)
            {
                selectionViewConstraintY = constraint
                break
            }
        }
    }
    
    private func positionSelectorViewWithPoint(point: CGPoint)
    {
        let colorSelected = colorPaletteView.colorAtPoint(point)
        delegate?.colorSelectionChanged(selectedColor: colorSelected)
        //self.view.backgroundColor = colorSelected
        colorSelectionView.backgroundColor = colorPaletteView.colorAtPoint(point)
        selectionViewConstraintX.constant = (point.x-colorSelectionView.bounds.size.width/2)
        selectionViewConstraintY.constant = (point.y-1.2*colorSelectionView.bounds.size.height)
    }
    
    private func startHidingSelectionView() {
        UIView.animateWithDuration(0.5, animations: {
            self.colorSelectionView.alpha = 0.0
        })
    }
}

/// UIView Subclass which displays a colors in little blocks.
@IBDesignable final public class SwiftColorView: UIView
{
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numColorsX * numColorsY`
    ///
    /// `Default` is 10
    @IBInspectable public var numColorsX:Int =  10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Number of color blocks in x-direction.
    ///
    /// Color palette size is `numColorsX * numColorsY`
    ///
    /// `Default` is 18
    @IBInspectable public var numColorsY:Int = 18 {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
    
    /// Wether or not the grid between the blocks should be visible.
    ///
    /// `Default` is false
    @IBInspectable public var showGridLines:Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var viewDataSource: SwiftColorPickerDataSource?
    
    public override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        let lineColor = UIColor.grayColor()
        let pS = patternSize()
        let w = pS.w
        let h = pS.h
        
        for y in 0..<numColorsY
        {
            for x in 0..<numColorsX
            {
                let path = UIBezierPath()
                let start = CGPointMake(CGFloat(x)*w+CGFloat(coloredBorderWidth),CGFloat(y)*h+CGFloat(coloredBorderWidth))
                path.moveToPoint(start);
                path.addLineToPoint(CGPointMake(start.x+w, start.y))
                path.addLineToPoint(CGPointMake(start.x+w, start.y+h))
                path.addLineToPoint(CGPointMake(start.x, start.y+h))
                path.addLineToPoint(start)
                path.lineWidth = 0.25
                colorForRectAt(x,y:y).setFill();
                
                if (showGridLines)
                {
                    lineColor.setStroke()
                }
                else
                {
                    colorForRectAt(x,y:y).setStroke();
                }
                path.fill();
                path.stroke();
            }
        }
    }
    
    private func colorForRectAt(x: Int, y: Int) -> UIColor
    {
        
        if let ds = viewDataSource {
            return ds.colorForPalletIndex(x, y: y, numXStripes: numColorsX, numYStripes: numColorsY)
        } else {
            
            var hue:CGFloat = CGFloat(x) / CGFloat(numColorsX)
            var fillColor = UIColor.whiteColor()
            if (y==0)
            {
                if (x==(numColorsX-1))
                {
                    hue = 1.0;
                }
                fillColor = UIColor(white: hue, alpha: 1.0);
            }
            else
            {
                let sat:CGFloat = CGFloat(1.0)-CGFloat(y-1) / CGFloat(numColorsY)
                fillColor = UIColor(hue: hue, saturation: sat, brightness: 1.0, alpha: 1.0)
            }
            return fillColor
        }
    }
    
    func colorAtPoint(point: CGPoint) -> UIColor
    {
        let pS = patternSize()
        let w = pS.w
        let h = pS.h
        let x = (point.x-CGFloat(coloredBorderWidth))/w
        let y = (point.y-CGFloat(coloredBorderWidth))/h
        return colorForRectAt(Int(x), y:Int(y))
    }
    
    private func patternSize() -> (w: CGFloat, h:CGFloat)
    {
        let width = self.bounds.width-CGFloat(2*coloredBorderWidth)
        let height = self.bounds.height-CGFloat(2*coloredBorderWidth)
        
        let w = width/CGFloat(numColorsX)
        let h = height/CGFloat(numColorsY)
        return (w,h)
    }
    
    public override func prepareForInterfaceBuilder()
    {
        print("Compiled and run for IB")
    }
    
}

public extension UIColor {

    /// Random `UIColor`
    class func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))/CGFloat(255)
        let g = CGFloat(arc4random_uniform(256))/CGFloat(255)
        let b = CGFloat(arc4random_uniform(256))/CGFloat(255)
        let a = CGFloat(arc4random_uniform(256))/CGFloat(255)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
