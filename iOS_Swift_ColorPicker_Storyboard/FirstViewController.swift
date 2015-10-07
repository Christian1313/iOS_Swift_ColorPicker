//
//  FirstViewController.swift
//  iOS_Swift_ColorPicker
//
//  Created by Christian Zimmermann on 03/03/15.
//  Copyright (c) 2015 Christian Zimmermann. All rights reserved.
//

import UIKit
import iOS_Swift_ColorPicker // framework with the Color Picker View Controller. XOu can simply tak the

class FirstViewController: UIViewController, UIPopoverPresentationControllerDelegate, SwiftColorPickerDelegate, SwiftColorPickerDataSource
{

    override func viewDidLoad() {
        super.viewDidLoad()
    }

   
    
    // MARK: - Segue Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let _ = segue.identifier
        {
            // adding as delegate for color selection
            let colorPickerVC = segue.destinationViewController as! SwiftColorPickerViewController
            colorPickerVC.delegate = self
            colorPickerVC.dataSource = self
            
            if let popPresentationController = colorPickerVC.popoverPresentationController {
                popPresentationController.delegate = self
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    

    // MARK: popover presenation delegates
    
    // this enables pop over on iphones
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.None
    }
    
    // MARK: - Color Matrix (only for test case)
    var colorMatrix = [ [UIColor]() ]
    private func fillColorMatrix(numX: Int, _ numY: Int) {
        colorMatrix.removeAll()
        if numX > 0 && numY > 0 {
            
            for _ in 0..<numX {
                var colInX = [UIColor]()
                for _ in 0..<numY {
                    colInX += [UIColor.randomColor()]
                }
                colorMatrix += [colInX]
            }
        }
    }
    
    
    // MARK: - Swift Color Picker Data Source
    
    func colorForPalletIndex(x: Int, y: Int, numXStripes: Int, numYStripes: Int) -> UIColor {
        if colorMatrix.count > x  {
            let colorArray = colorMatrix[x]
            if colorArray.count > y {
                return colorArray[y]
            } else {
                fillColorMatrix(numXStripes,numYStripes)
                return colorForPalletIndex(x, y:y, numXStripes: numXStripes, numYStripes: numYStripes)
            }
        } else {
            fillColorMatrix(numXStripes,numYStripes)
            return colorForPalletIndex(x, y:y, numXStripes: numXStripes, numYStripes: numYStripes)
        }

    }
    
    
    
    // MARK: Color Picker Delegate
    
    func colorSelectionChanged(selectedColor color: UIColor) {
    
        self.view.backgroundColor = color
    }
    
    
    
    
    

}
