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
        /* Unwrap meme and set the image view to the memed image */
        if let meme = meme {
            detailImageView.image = meme.memedImage
        }
    }
    
}
