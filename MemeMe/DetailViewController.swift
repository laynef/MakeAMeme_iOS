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
    
    var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let meme = meme {
            detailImageView.image = meme.memedImage
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeEditor" {
            let editVC = segue.destinationViewController as! FirstViewController
            editVC.editMeme = meme
            
            editVC.userIsEditing = true
        }
    }
    
}
