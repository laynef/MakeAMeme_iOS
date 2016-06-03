//
//  CollectionViewCell.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func isSelected(selected: Bool) {
        if selected {
            imageView.hidden = false
        } else {
            imageView.hidden = true
        }
    }
    
}
