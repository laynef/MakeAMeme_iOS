//
//  ColorPickerViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 6/3/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

public protocol ColorPickerDelegate {
    func colorSelectionChanged(selectedColor color: UIColor)
}

public protocol ColorPickerDataSource: class {
    func colorForPalletIndex(x: Int, y: Int, numXStripes: Int, numYStripes: Int) -> UIColor
}

class ColorPickerViewController: UIViewController {

    internal var delegate: ColorPickerDelegate?
    
    internal weak var dataSource: ColorPickerDataSource? {
    didSet {
        colorPaletteView.viewDataSource = dataSource
        }
    }
    
    internal var coloredBorderWidth:Int = 10 {
    didSet {
        colorPaletteView.coloredBorderWidth = coloredBorderWidth
        }
    }

    internal var colorPreviewDiameter:Int = 35 {
    didSet {
        setConstraintsForColorPreView()
        }
    }

    internal var numberColorsInXDirection: Int = 10 {
    didSet {
    colorPaletteView.numColorsX = numberColorsInXDirection
    }
    }

    internal var numberColorsInYDirection: Int = 18 {
    didSet {
    colorPaletteView.numColorsY = numberColorsInYDirection
    }
    }
    
    private var colorPaletteView: SwiftColorView = SwiftColorView()
    private var colorSelectionView: UIView = UIView()
    
    private var selectionViewConstraintX: NSLayoutConstraint = NSLayoutConstraint()
    private var selectionViewConstraintY: NSLayoutConstraint = NSLayoutConstraint()
    
    
    internal required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    }
    
    internal override func loadView()
    {
    super.loadView()
    if ( !(self.view is SwiftColorView) )
    {
    let s = colorPaletteView
    s.translatesAutoresizingMaskIntoConstraints = false
    s.contentMode = UIViewContentMode.Redraw
    s.userInteractionEnabled = true
    self.view = s
    }
    else
    {
    colorPaletteView = self.view as! SwiftColorView
    }
    coloredBorderWidth = colorPaletteView.coloredBorderWidth
    numberColorsInXDirection = colorPaletteView.numColorsX
    numberColorsInYDirection = colorPaletteView.numColorsY
    }
    
    internal override func viewDidLoad() {
    super.viewDidLoad()

    colorSelectionView.translatesAutoresizingMaskIntoConstraints = false
    

    colorPaletteView.addSubview(colorSelectionView)

    setConstraintsForColorPreView()
    

    colorSelectionView.layer.masksToBounds = true
    colorSelectionView.layer.borderWidth = 0.5
    colorSelectionView.layer.borderColor = UIColor.grayColor().CGColor
    colorSelectionView.alpha = 0.0
    
    

    let tapGr = UITapGestureRecognizer(target: self, action: #selector(ColorPickerViewController.handleGestureRecognizer(_:)))
    let panGr = UIPanGestureRecognizer(target: self, action: #selector(ColorPickerViewController.handleGestureRecognizer(_:)))
    panGr.maximumNumberOfTouches = 1
    colorPaletteView.addGestureRecognizer(tapGr)
    colorPaletteView.addGestureRecognizer(panGr)
    colorPaletteView.viewDataSource = dataSource
    }
    
    
    internal override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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

    @IBDesignable final public class SwiftColorView: UIView
    {

        @IBInspectable public var numColorsX:Int =  10 {
            didSet {
                setNeedsDisplay()
            }
        }
        

        @IBInspectable public var numColorsY:Int = 18 {
            didSet {
                setNeedsDisplay()
            }
        }
        

        @IBInspectable public var coloredBorderWidth:Int = 10 {
            didSet {
                setNeedsDisplay()
            }
        }
        

        @IBInspectable public var showGridLines:Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }
        
        weak var viewDataSource: ColorPickerDataSource?
        
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
        
        class func randomColor() -> UIColor {
            let r = CGFloat(arc4random_uniform(256))/CGFloat(255)
            let g = CGFloat(arc4random_uniform(256))/CGFloat(255)
            let b = CGFloat(arc4random_uniform(256))/CGFloat(255)
            let a = CGFloat(arc4random_uniform(256))/CGFloat(255)
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
}
