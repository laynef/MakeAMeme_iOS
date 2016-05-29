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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        frameTableLayout.delegate = self
        frameTableLayout.dataSource = self
        frameTableLayout?.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMemes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let Controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! DetailViewController
        
        if savedMemes.count > 0 {
            currentMeme = savedMemes[indexPath.row]
            currentMeme.index = indexPath.row
            navigationController!.pushViewController(Controller, animated: true)
        }

    }

    @IBAction func addMeme(sender: AnyObject) {
        memeIndex += 1
    }

}
