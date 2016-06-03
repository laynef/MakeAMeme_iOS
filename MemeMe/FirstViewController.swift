//
//  ViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/17/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

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
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var editMeme: Meme?
    var selectedTextField: UITextField?
    var userIsEditing = false
    
    //#-MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Congifure the UI to its default state */
        setDefaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        /* Disable camera button if no camera is available */
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubsribeToKeyboardNotification()
    }
    
    /* Hide status bar to avoid bug where status bar shows when imageview pushed up by keyboard */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /* Set the state of the User Interface to editing or creating
     If you are editing a Meme, then configure and set the appropriate fields
     Otherwise, configure default state for text fields */
    func setDefaultUIState() {
        let textFieldArray = [topTextField, bottomTextField]
        
        /* Set the meme to edit if there is an editMeme */
        if let editMeme = editMeme {
            memeNavBar.topItem?.title = "Edit your Meme"
            
            topTextField.text = editMeme.topText
            bottomTextField.text = editMeme.bottomTexxt
            imageView.image = editMeme.originalImage
            
            userIsEditing = true
            configureTextFields(textFieldArray)
        } else {
            //Set the title if creating a Meme */
            memeNavBar.topItem?.title = "Create a Meme"
            configureTextFields(textFieldArray)
        }
        
        /* Hide or Show the buttons based on whether the user is editing */
        cancelButton.enabled = userIsEditing
        actionButton.enabled = userIsEditing
    }
    
    /* Pass an array of text fields and set the default text attributes for each */
    func configureTextFields(textFields: [UITextField!]){
        for textField in textFields{
            textField.delegate = self
            textField.textAlignment = .Center
        }
    }
    
    /* Check if the photo album is available
     then Select and return an image from the photo library */
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
    
    /* If available, select an image from the camera */
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /* Alert the user if something is missing from the meme when they try to save */
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* Clear the view if user presses cancel */
    func clearView() {
        imageView.image = nil
        topTextField.text = nil
        bottomTextField.text = nil
    }
    
    /* Create the meme and save it to the Meme Model */
    @IBAction func saveMeme(sender: AnyObject) -> Void {
        
        /* Check If all items are filled out */
        if userCanSave() {
            
            /* Initialize a new meme to save or update */
            let meme = Meme(topText: topTextField.text!, bottomTexxt: bottomTextField.text!, originalImage: memedImage, memedImage: generateMemedImage())
            
            /* If you are editing a meme, update it, if new, save it */
            if userIsEditing {
                
                /* Unwrap then update the meme if there is one to update */
                if let editMeme = editMeme {
                    CollectedMemes.update(atIndex: CollectedMemes.indexOf(editMeme), withMeme: meme)
                }
                
            } else {
                /* Add the Meme if user is not editing */
                CollectedMemes.add(meme)
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            /* Alert user if something is missing and you can't save */
            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topTextField.text = ""
                self.bottomTextField.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }
    }
    
    /* Test to see whether the user can save or not */
    func userCanSave() -> Bool {
        if topTextField.text == nil || bottomTextField.text == nil || imageView.image == nil {
            return false
        } else {
            return true
        }
    }
    
    func generateMemedImage() -> UIImage {
        /* Hide everything but the image */
        hideNavItems(true)
        
        /* render view to an image */
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* Show all views that were hidden */
        hideNavItems(false)
        
        return memedImage
    }
    
    private func hideNavItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        memeNavBar.hidden = hide
        memeToolBar.hidden = hide
    }
    
    /* Present the ActivityViewController programmatically to share a Meme */
    @IBAction func didTapShare(sender: UIBarButtonItem) {
        
        let ac = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveMeme(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* If no memes, clear the view, otherwise dismiss the view */
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if CollectedMemes.allMemes.count == 0 {
            clearView()
        }else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /* Popover delegate method */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

//# -- MARK Extend UIImagePickerDelegate Methods for MemeEditorViewController
extension FirstViewController {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//#-MARK: Extension for the UITextFieldDelegate and Keyboard Notification Methods for MemeEditorViewController
extension FirstViewController {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        configureTextFields([textField])
        
        /* Enable save button if fields are filled and resign first responder */
        actionButton.enabled = userCanSave()
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        /* Enable save button if fields are filled out  */
        actionButton.enabled = userCanSave()
        configureTextFields([topTextField, bottomTextField])
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        if selectedTextField == bottomTextField && view.frame.origin.y == 0.0 {
            
            view.frame.origin.y = -getKeyboardHeight(notification)
            actionButton.enabled = false
            
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        actionButton.enabled = userCanSave()
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}