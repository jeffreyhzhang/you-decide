//
//  TwitterVC.swift
//
//  TwitterAnalysis
//
//  Created by Jeffrey Zhangon 4/24/15.
//  Copyright (c) 2015  All rights reserved.
//

import UIKit
import Social
import Accounts
import CoreData
 
class TwitterVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var dataFilePath: String?
    var mytwitterHandle: String!
    
    let context = CoreDataManager.sharedInstance().managedObjectContext!
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    
    @IBOutlet weak var tweetTblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        var since_id = Utilities.getDatafromDefaults(mytwitterHandle)
        
        WebUtilities.sharedInstance().getTimeLine(mytwitterHandle, since_id: since_id){
        (error) in
            if (error != nil){
                Utilities.showAlert(self, title: "Error", message: "\(error!.userInfo)")
            } else {
            
                WebUtilities.Alltweets = self.fetchedResultsController.fetchedObjects as! [Tweet]
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tweetTblVw.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //hide top nav
       self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tweet = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Tweet
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        var indate = formatter.dateFromString(tweet.createdAt)!
        
        
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .ShortStyle
        
        let dateString = formatter.stringFromDate(indate)
        
        var txt : String = "Tweeted@ "
        txt +=  dateString
        txt += " with "
        txt += toString(tweet.likes)
        txt += " likes and "
        txt +=  toString(tweet.retweets)
        txt += " retweets"
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as!  TweetCellVC  
        
        
        cell.lblheader.text = txt
        cell.lblTweet.text =  tweet.text
        
        cell.lblheader.font = UIFont.boldSystemFontOfSize(10)
        Utilities.AutoSizeLabelField(cell.lblheader, minScaleFactor: 0.3)
        
        cell.lblTweet.font = UIFont.boldSystemFontOfSize(8)
        Utilities.AutoSizeLabelField(cell.lblTweet, minScaleFactor: 0.2)
    
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //when selected,  current tweet to chartVC
        
        //  we can use prepareSegue
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.navigationBarHidden = false
        
        // This is tweet ranking # in all the tweets
        let tweet = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Tweet
        
        WebUtilities.CurrentTweet = tweet
        WebUtilities.Alltweets = self.fetchedResultsController.fetchedObjects as! [Tweet]
        
        self.performSegueWithIdentifier("ShowCharts", sender: self)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(WebUtilities.Constants.Entity_Tweet, inManagedObjectContext: context)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        
        //predicates
        let searchValue : Star = WebUtilities.CurrentStar!
        fetchRequest.predicate = NSPredicate(format: "( star == %@)", searchValue)
        

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "id_str", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: WebUtilities.Constants.TwitterCaheName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        
        //make it available for everyone in this App
        WebUtilities.Alltweets = self.fetchedResultsController.fetchedObjects as! [Tweet]
        
        
        return _fetchedResultsController!
    }
    
    override func viewWillDisappear(animated: Bool) {
        //clear cache before exit
        NSFetchedResultsController.deleteCacheWithName(WebUtilities.Constants.TwitterCaheName)
        _fetchedResultsController = nil;
 
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
}

 