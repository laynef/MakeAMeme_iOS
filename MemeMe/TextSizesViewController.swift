//
//  TextSizesViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 6/3/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class TextSizesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontPicker: UIPickerView!
    
    var fontAttributes: FontAttributes!
    var pickerData = [String]()
    let fontFamily = UIFont.familyNames()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        fontPicker.dataSource = self
        fontPicker.delegate = self

        setFontAttributeDefaults(fontAttributes.fontSize, fontName: fontAttributes.fontName, fontColor: fontAttributes.fontColor)
        setValuesOfUIElementsForFontAttributes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToShakeNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToShakeNotification()
    }

    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.setValuesOfUIElementsForFontAttributes()
            self.updateMemeFont()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    

    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = fontSize
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
    

    func setValuesOfUIElementsForFontAttributes() {
    
        fontSizeSlider.value = Float(fontAttributes.fontSize)
        
     
        let index = pickerData.indexOf(fontAttributes.fontName)
        if let index = index {
            fontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    

    func updateMemeFont(){
        let parent = presentingViewController as! FirstViewController
        parent.fontAttributes.fontSize = fontAttributes.fontSize
        parent.fontAttributes.fontName = fontAttributes.fontName
        parent.configureTextFields([parent.topText, parent.bottomText])
    }
    

    @IBAction func didChangeSlider(sender: UISlider) {
        
        let fontSize = CGFloat(fontSizeSlider.value)
        fontAttributes.fontSize = fontSize
        
        updateMemeFont()
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fontAttributes.fontName = pickerData[row]
        updateMemeFont()
    }


}
