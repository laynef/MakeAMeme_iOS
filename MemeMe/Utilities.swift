//
//  Utilies.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

struct Meme {
    var topText: String
    var bottomTexxt: String
    var originalImage: UIImage
    var memedImage: UIImage
    var index: Int
    
}

var savedMemes = [Meme]()
var currentMeme: Meme!
var memeIndex: Int = 0