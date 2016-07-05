//
//  ViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/17/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var editMeme: Meme?
    var fontAttributes: FontAttributes!
    var selectedTextField: UITextField?
    var userIsEditing = false
    
    //#-MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        subscribeToKeyboardNotification()
        subscribeToShakeNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        unsubsribeToKeyboardNotification()
        unsubsribeToShakeNotification()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setDefaultUIState() {
        let textFieldArray = [topText, bottomText]
        
        if let editMeme = editMeme {
            navBar.topItem?.title = "Edit your Meme"
            
            topText.text = editMeme.topText
            bottomText.text = editMeme.bottomTexxt
            imageView.image = editMeme.originalImage
            
            userIsEditing = true
            fontAttributes = editMeme.fontAttributes
            configureTextFields(textFieldArray)
        } else {
            navBar.topItem?.title = "Create a Meme"
            fontAttributes = FontAttributes()
            configureTextFields(textFieldArray)
        }
        
        shareButton.enabled = userIsEditing
        cancelButton.enabled = userIsEditing
    }
    
    func configureTextFields(textFields: [UITextField!]){
        for textField in textFields{
            textField.delegate = self
            
            /* Define default Text Attributes */
            let memeTextAttributes = [
                NSStrokeColorAttributeName: UIColor.blackColor(),
                NSForegroundColorAttributeName: fontAttributes.fontColor,
                NSFontAttributeName: UIFont(name: fontAttributes.fontName, size: fontAttributes.fontSize)!,
                NSStrokeWidthAttributeName : -4.0
            ]
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }
    
    @IBAction func selectImageFromCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            /* Initialize and present the imagepicker */
            imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.allowsEditing = false
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func clearView() {
        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
    }
    
    @IBAction func saveMeme(sender: AnyObject) -> Void {

        if userCanSave() {
            
            let meme = Meme(topText: topText.text, bottomTexxt: bottomText.text, originalImage: imageView.image, memedImage: generateMemedImage(), fontAttributes: fontAttributes)

            if userIsEditing {

                if let editMeme = editMeme {
                    CollectedMemes.update(atIndex: CollectedMemes.indexOf(editMeme), withMeme: meme)
                }
     
                performSegueWithIdentifier("unwindMemeEditor", sender: sender)
                
            } else {
                CollectedMemes.add(meme)
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {

            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topText.text = ""
                self.bottomText.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }
    }
    
    func userCanSave() -> Bool {
        if topText.text == nil || bottomText.text == nil || imageView.image == nil {
            return false
        } else {
            return true
        }
    }
    
    func generateMemedImage() -> UIImage {
        hideNavItems(true)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        hideNavItems(false)
        
        return memedImage
    }
    
    private func hideNavItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        navBar.hidden = hide
        bottomToolbar.hidden = hide
    }
    
    @IBAction func didTapShare(sender: UIBarButtonItem) {
        
        let ac = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveMeme(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if CollectedMemes.allMemes.count == 0 {
            clearView()
        }else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func colorSelectionChanged(selectedColor color: UIColor) {
        fontAttributes.fontColor = color
        configureTextFields([topText, bottomText])
    }
    
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            /* Reset to default values and update the Meme's font */
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.updateMemeFont()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func updateMemeFont(){
        configureTextFields([topText, bottomText])
    }

    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = CGFloat(fontSize)
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
}

extension FirstViewController {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
        
        shareButton.enabled = userCanSave()
        cancelButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FirstViewController {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        configureTextFields([textField])
        
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)

        configureTextFields([topText, bottomText])
    }
    
    func keyboardWillShow(notification: NSNotification) {
 
        if selectedTextField == bottomText && view.frame.origin.y == 0.0 {
            
            view.frame.origin.y = -getKeyboardHeight(notification)
            
        }
    }
    

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}


extension UIViewController {
    
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.alertForReset), name: "shake", object: nil)
    }
    
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
        }
    }

    
}