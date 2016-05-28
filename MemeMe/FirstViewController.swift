//
//  ViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/17/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Meme {
        var topText: String
        var bottomTexxt: String
        var originalImage: UIImage
        var memedImage: UIImage
    }

    @IBOutlet var wholeMemeView: UIView!
    @IBOutlet weak var topTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var memeToolBar: UIToolbar!
    @IBOutlet weak var memeNavBar: UINavigationBar!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    var combinedMeme: UIImage!
    var savedMemes = [Meme]()
    
    @IBAction func pickAnImage(sender: AnyObject) {
        pickerControllerActions(.SavedPhotosAlbum)
    }
    
    @IBAction func showCameraController(sender: UIBarButtonItem) {
        pickerControllerActions(.Camera)
    }
    
    @IBAction func actionButtonActions(sender: UIBarButtonItem) {
        combinedMeme = generateMemedImage()
        let actViewController = UIActivityViewController(activityItems: [combinedMeme], applicationActivities: nil)
        self.presentViewController(actViewController, animated: true, completion: nil)
        saveMeme()
    }
    
    @IBAction func cancelButtonAction(sender: UIBarButtonItem) {
        initialStateOfMeme()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialStateOfMeme()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraEnablable()
        self.subscribeKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.unsubscribeKeyboardNotification()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func pickerControllerActions(type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func cameraEnablable() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            cameraButton.enabled = true
        } else {
            cameraButton.enabled = false
        }
    }
    
    func subscribeKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification,object:nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfoDict = notification.userInfo, keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue().height
            UIView.animateWithDuration(0.8) {
                if (self.bottomTextField.isFirstResponder()) {
                    self.wholeMemeView.frame.origin.y = keyboardFrame * -1
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.8) {
            if (self.bottomTextField.isFirstResponder()) {
                self.wholeMemeView.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setAttributedStringValue() -> [String : AnyObject] {
        let memeTextAttri = [   NSStrokeColorAttributeName: UIColor.blackColor(),
                                NSForegroundColorAttributeName: UIColor.whiteColor(),
                                NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                                NSStrokeWidthAttributeName: -3.0]
        return memeTextAttri
    }
    
    func setPlaceHolderAttributedStringValue(placeholderTxt: String) -> NSAttributedString {
        let placeHolderASV = NSAttributedString(string: placeholderTxt, attributes: [
            NSForegroundColorAttributeName:UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -3.0]
        )
        return placeHolderASV
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func saveMeme() {
        let currentMeme = Meme(topText: topTextField.text!, bottomTexxt: bottomTextField.text!, originalImage: imageView.image!, memedImage: combinedMeme)
        savedMemes.append(currentMeme)
    }
    
    func initialStateOfMeme() {
        actionButton.enabled = false
        imageView.backgroundColor = UIColor.blackColor()
        imageView.image = nil
        placeHolderText(topTextField, text: "TOP")
        placeHolderText(bottomTextField, text: "BOTTOM")
    }
    
    func placeHolderText(textField: UITextField, text: String) {
        textField.text = ""
        textField.defaultTextAttributes = setAttributedStringValue()
        textField.attributedPlaceholder = setPlaceHolderAttributedStringValue(text)
        textField.textAlignment = .Center
        textField.delegate = self
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let userSelectedImageVal = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = userSelectedImageVal
        actionButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        memeToolBar.hidden = true
        memeNavBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        memeToolBar.hidden = false
        memeNavBar.hidden = false
        
        return memedImage
    }
    
}

