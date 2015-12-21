//
//  TableViewController.swift
//  InstagramClone
//
//  Created by alex oh on 12/21/15.
//  Copyright © 2015 Alex Oh. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {

    var usernames: [String] = []
    var userids: [String] = []
    var isFollowing: [String:Bool] = [:]
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        usernames = []
        userids = []
        isFollowing = [:]
        
        var query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId != PFUser.currentUser()?.objectId {
                            
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            var query = PFQuery(className: "Followers")
                            query.whereKey("followers", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                    } else {
                                        
                                        self.isFollowing[user.objectId!] = false
                                    }
                                    
                                }
                                
                               
                                if self.isFollowing.count == self.usernames.count {
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()

                                }
                            })
                        }
                        
                    }
                    
                }
                
            }
            
            
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresher)
        self.tableView.sendSubviewToBack(refresher)
        
        refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell = tableView.cellForRowAtIndexPath(indexPath)

        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "Followers")

            following["following"] = userids[indexPath.row]
            following["followers"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
            
        } else {
            
            isFollowing[followedObjectId] = false
            
            cell?.accessoryType = UITableViewCellAccessoryType.None

            var query = PFQuery(className: "Followers")
            query.whereKey("followers", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                   
                    for object in objects {
                        
                        object.deleteInBackground()
                        
                    }
                   
                }
                
            })
            
        }
    }

}
