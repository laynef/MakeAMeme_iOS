//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet var collectionFrameLayout: UICollectionView!
    
    let minimumSpacing: CGFloat = 5.0
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    var selectedMemes = [NSIndexPath]()
    var editingMode = false
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionFrameLayout.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setDefaultUIState()
    }
    
    func setDefaultUIState () {

        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(MemeCollectionViewController.didTapEdit(_:)))
        addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MemeCollectionViewController.launchEditor(_:)))
        
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.leftBarButtonItem?.enabled = CollectedMemes.allMemes.count > 0
        

        for index in selectedMemes {
            collectionFrameLayout.deselectItemAtIndexPath(index, animated: true)
            let cell = collectionFrameLayout.cellForItemAtIndexPath(index) as! CollectionViewCell
            cell.isSelected(false)
        }
        

        selectedMemes.removeAll()
        collectionFrameLayout.reloadData()
        
        editingMode = false
        
  
        if CollectedMemes.allMemes.count == 0 {
            editButton.enabled = false
            launchEditor(self)
        } else {
            editButton.enabled = true
        }
    }
    

    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode
        

        if editingMode {
            
            editButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(MemeCollectionViewController.didTapEdit(_:)))
            navigationItem.leftBarButtonItem = editButton
            

            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(MemeCollectionViewController.alertBeforeDeleting(_:)))
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
  
            setDefaultUIState()
        }
    }
    

    func launchEditor(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("FirstViewController")
        let editMemeVC = object as! FirstViewController
        
        presentViewController(editMemeVC, animated: true, completion: {
            editMemeVC.cancelButton.enabled = true
            editMemeVC.shareButton.enabled = true
        })
    }
}


extension MemeCollectionViewController {
    

    func deleteSelectedMemes(sender: AnyObject) {
        if selectedMemes.count > 0 {
            
      
            let sortedMemes = selectedMemes.sort {
                return $0.item > $1.item
            }
            
       
            for index in sortedMemes {
                CollectedMemes.remove(atIndex: index.item)
            }
            setDefaultUIState()
        }
    }
    

    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you SURE that you want to delete the selected Memes?", preferredStyle: .Alert)
        
        let deleteAction = UIAlertAction(title: "Delete!", style: .Destructive, handler: {
            action in self.deleteSelectedMemes(sender)
        })
        
        let stopAction = UIAlertAction(title: "Keep Them", style: .Default, handler: {
            action in self.setDefaultUIState()
        })
        
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        presentViewController(ac, animated: true, completion: nil)
    }
}


extension MemeCollectionViewController {
    

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CollectedMemes.allMemes.count
    }
    

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let meme = CollectedMemes.allMemes[indexPath.item]
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        

        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
            
            selectedMemes.append(indexPath)
            cell.isSelected(true)
            addDeleteButton.enabled = true
            
        } else {
            

            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController")
            let detailVC = object as! DetailViewController
            
            detailVC.meme = CollectedMemes.allMemes[indexPath.item]
            navigationController!.pushViewController(detailVC, animated: true)
            
        }
    }
    

    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        

        navigationItem.rightBarButtonItem?.enabled = (selectedMemes.count > 0)
        
      
        if editingMode {
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
            selectedMemes.removeAtIndex(indexPath.item)
            cell.isSelected(false)
            
        }
    }
    
}
