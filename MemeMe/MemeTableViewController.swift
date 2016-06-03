//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Layne Faler on 5/28/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    @IBOutlet var frameTableLayout: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    /* If no saved Memes, present the Meme Creator when view will appear */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if CollectedMemes.count() == 0 {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("FirstViewController")
            let memeCreatorVC = object as! FirstViewController
            presentViewController(memeCreatorVC, animated: false, completion: nil)
        }
        navigationItem.leftBarButtonItem?.enabled = CollectedMemes.count() > 0
        tableView!.reloadData()
    }
    
    
    /* Present the meme creator with cancel button enabled */
    @IBAction func didPressAdd(sender: AnyObject) {
        /* Programmatic segue presents the MemeEditor in creation mode */
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("FirstViewController")
        let newMemeVC = object as! FirstViewController
        presentViewController(newMemeVC, animated: true, completion: {
            newMemeVC.cancelButton.enabled = true
        })
    }
    
    @IBAction func unwindMemeEditor(segue: UIStoryboardSegue) {
        tableView!.reloadData()
    }
    
    /* Delegate methods for editing the table view */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    /* Set editing and configure the UI accordingly */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if !tableView.editing {
            tableView.setEditing(editing, animated: animated)
        }
    }
}

// MARK: - Extend MemeTableViewController for TableView data source & delegate methods
extension MemeTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Set the number of rows in section based on count of Memes */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CollectedMemes.count()
    }
    
    /* Configure table view cells */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath)
        
        let meme = CollectedMemes.allMemes[indexPath.row]
        cell.textLabel!.text = "\(meme.topText) \(meme.bottomTexxt)"
        cell.imageView!.image = meme.originalImage
        
        return cell
    }
    
    /* Allow tableView editing */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Delete Meme when selected */
        switch editingStyle {
        case .Delete:
            
            CollectedMemes.remove(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            /* If there are no saved Memes, present the Meme Creator */
            if CollectedMemes.count() == 0 {
                let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("FirstViewController")
                let memeCreatorVC = object as! FirstViewController
                presentViewController(memeCreatorVC, animated: false, completion: nil)
            }
            
        default:
            
            return
            
        }
        
    }
    
    /* Show detail View from selection */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* If not editing, perform segue defined in storyboard */
        if !tableView.editing {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController")
            let detailVC = object as! DetailViewController
            
            /* Pass the data from the selected row to the detail view and present it */
            detailVC.meme = CollectedMemes.allMemes[indexPath.row]
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
}
