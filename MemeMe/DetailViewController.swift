//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        detailImageView.image = currentMeme.memedImage
        tabBarController?.tabBar.hidden = true
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
        navigationController?.setToolbarHidden(false, animated: false)
    }

    @IBAction func removeMeme(sender: AnyObject) {
        savedMemes.removeAtIndex(currentMeme.index)
        memeIndex -= 1
    }

    @IBAction func editMeme(sender: AnyObject) {
        let memeEditorViewController = storyboard?.instantiateViewControllerWithIdentifier("FirstViewController") as! FirstViewController
        presentViewController(memeEditorViewController, animated: true, completion: nil)
    }
    
}
