//
//  FirstViewController.swift
//  iOS_Swift_ColorPicker
//
//  Created by Christian Zimmermann on 03/03/15.
//  Copyright (c) 2015 Christian Zimmermann. All rights reserved.
//

import UIKit
import iOS_Swift_ColorPicker // framework with the Color Picker View Controller. XOu can simply tak the

class FirstViewController: UIViewController, UIPopoverPresentationControllerDelegate, SwiftColorPickerDelegate
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
    
    // MARK: Color Picker Delegate
    
    func colorSelectionChanged(selectedColor color: UIColor) {
    
        self.view.backgroundColor = color
    }
    
    
    

}
