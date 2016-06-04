//
//  Utilies.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

struct FontAttributes {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}

struct Meme {
    var topText: String!
    var bottomTexxt: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    var fontAttributes: FontAttributes!
}

func ==(lhs: Meme, rhs: Meme) -> Bool {
    return lhs.memedImage == rhs.memedImage
}

struct CollectedMemes {
    
    static var allMemes: [Meme] {
        return getMemeStorage().memes
    }
    
    static func getMeme(atIndex index: Int) -> Meme {
        return allMemes[index]
    }
    
    static func indexOf(meme: Meme) -> Int {
        
        if let index = allMemes.indexOf({$0 == meme}) {
            return Int(index)
        } else {
            print(allMemes.count)
            return allMemes.count
        }
    }
    
    static func add(meme: Meme) {
        getMemeStorage().memes.append(meme)
    }
    
    static func update(atIndex index: Int, withMeme meme: Meme) {
        getMemeStorage().memes[index] = meme
    }
    
    static func remove(atIndex index: Int) {
        getMemeStorage().memes.removeAtIndex(index)
    }
    
    static func count() -> Int {
        return getMemeStorage().memes.count
    }
    
    static func getMemeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
    
}