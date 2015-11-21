# iOS ColorPicker
**Written completely in Swift**.

![ColorPicker ScreenShot](../master/Screenshots/Image01_Thumb.png)

## Overview
The Color Picker constist of a ``SwiftColorView`` and a ``SwiftColorPickerViewController``. By Tapping or panning on the view the ``SwiftColorPickerDelegate`` is notfied about the changed color.

To customize the colors displayed by the ``SwiftColorPickerViewController`` implement the ``SwiftColorPickerDataSource`` protocoll and the caller class as the `dataSource` of the  ``SwiftColorPickerViewController``.

In the Repository are two Example projects, which show how to utilize the ``SwiftColorPickerViewController``. 

- Using the ViewController in a storyboard
- Creating and using the ViewController programmatically

The ``SwiftColorView``is ``@IBDesignable``so it will render nicely in InterfaceBuilder.

![SwiftColorView in InterfaceBuilder](../master/Screenshots/Image02_Thumb.png)


## Usage
Copy the ``SwiftColorPickerViewController.swift``into your project. 

### Add ViewController in a Storyboard
+ Add a View Controller
+ Set View Class to ``SwiftColorPickerViewController``
+ Select View and set Class of View to ``SwiftColorView``

https://www.youtube.com/watch?v=VtV5bI_UBo4

You can change the porpertis of the ``SwiftColorView``in the inspector.

### Add ViewController Programmatically

+ Instantiate a picker object
+ add a delegate

``let colorPickerVC = SwiftColorPickerViewController()``

``colorPickerVC.delegate = self``

+ (optional) add a dataSource

``colorPickerVC.dataSource = self``

**Parameters:**

+ Number of color blocks in x-direction. Color palette size is numberColorsInXDirection * numberColorsInYDirection

	`` colorPickerVC.numberColorsInXDirection = 20;``

+ Number of color blocks in y-direction. Color palette size is numberColorsInXDirection * numberColorsInYDirection

     ``colorPickerVC.numberColorsInYDirection = 20;``
     
+ Width of the edge around the color palette. The border change the color with the selection by the user. Default is 10

	``colorPickerVC.coloredBorderWidth = 10;``
          
+ Diameter of the circular view, which preview the color selection. The preview will apear at the fimnger tip of the users touch and show se current selected color. 

	``colorPickerVC.colorPreviewDiameter = 44;``     

### Custom keyboard implement in a Storyboard

## Usage
Copy the ``SwiftColorPickerView.swift``into your project. 
Copy the ``ColorPickerTextField.swift``into your project.

### Add ViewController in a Storyboard
+ Add a View Controller with a textField (or any element that acepts an inputView (ie keyboard))
+ Set the element's' Class to ``ColorPickerTextField``
      
## More

If you like the code write me.
