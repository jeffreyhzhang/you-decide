//
//  HomeVC.swift
//  TwitterAnalysis
//
//  Created by JeffreyLee on 4/27/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//


import Foundation
import UIKit
import CoreData


class HomeVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tweetAcctTableView: UITableView!
    
    let context = CoreDataManager.sharedInstance().managedObjectContext!
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    // eidt/done toggle
    
    override func  setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    override func viewWillAppear(animated: Bool) {
  
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButton:")
        self.navigationItem.rightBarButtonItem = refreshButton

         if( self.fetchedResultsController.fetchedObjects?.count == 0){
            self.navigationItem.leftBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem?.enabled = false
        }else{
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
       
        //  show bottom tab
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    //resfresh stars....more followers
    
    func refreshButton(sender: AnyObject?){
        refreshAll()
     }
    
    
    func refreshAll(){
        
        //loop all twiiter acct and get latest followers #
        if(self.fetchedResultsController.fetchedObjects?.count > 0){
            let istart = self.fetchedResultsController.fetchedObjects?.startIndex
            let iend = self.fetchedResultsController.fetchedObjects?.endIndex
            
            for idx in istart! ... iend! - 1 {
                let wkingacct = self.fetchedResultsController.fetchedObjects?[idx] as! Star
                let twitterhandle = wkingacct.twitteracct
                
                WebUtilities.sharedInstance().getTwitterUser(self, mytwitterHandle: twitterhandle, completionHandler: { (tweetAcct, error) -> Void in
                    if(error != nil){
                        Utilities.showAlert(self, title: "Error", message: "Error refreshing")
                        return
                    }
                    if  tweetAcct != nil {
                        //save to NSDefault: lastupdate tiemstamp
                        let mylastupdateKey = WebUtilities.Constants.TwitterLastUpdated + twitterhandle
                        Utilities.saveDatatoDefaults(mylastupdateKey, value: Utilities.NowSTimestamp())
                    }
                })
            }
            //update star
            CoreDataManager.sharedInstance().saveContext()
            
            // refresh table
            dispatch_async(dispatch_get_main_queue()) {
                self.self.tweetAcctTableView!.reloadData()
            }
        }
    }
    
    // MARK: - Dismiss Keyboard
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
 
        let CellReuseId = "AccountCell"
        let tweetAcct =   self.fetchedResultsController.objectAtIndexPath(indexPath) as! Star
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as! AcctCell
        configureCell(cell,  tweetAcct: tweetAcct)
        
        return cell 
    }
    
    
    //change followers ...rest SHOULD not change
    func configureCell(cell: AcctCell,  tweetAcct: Star) {
        
        cell.lblAccount.text =  tweetAcct.twitteracct
        let mylastupdateKey = WebUtilities.Constants.TwitterLastUpdated + tweetAcct.twitteracct
        var lstUpdateDT = Utilities.getDatafromDefaults(mylastupdateKey)
        
        if (lstUpdateDT.isEmpty || count(lstUpdateDT) < 3) {
           lstUpdateDT =  Utilities.NowSTimestamp()
            Utilities.saveDatatoDefaults(mylastupdateKey, value: lstUpdateDT)
        }
        
        cell.lblFollowers.text  = toString(tweetAcct.followersCount) + " followers as of " + lstUpdateDT
        cell.lblAccount.font =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 14)!
        
        //image hanlder...
        
        let imageUrlString = tweetAcct.photoUrl
        var imageURL = split(imageUrlString) {$0 == "/"}
        cell.imgvw.image = WebUtilities.Caches.imageCache.imageWithIdentifier(imageURL.last!)
        
    }

    
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        let total = self.fetchedResultsController.fetchedObjects?.count ?? 0
       //save so we can switch tab when load or after deleting
        Utilities.saveDatatoNSKey(total)
        return total
    }
    
    
     
    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !Utilities.isConnectedToNetwork() {
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
      
        //save to DB before I leave
        CoreDataManager.sharedInstance().saveContext()
        
        let itm :Star =  self.fetchedResultsController.objectAtIndexPath(indexPath) as! Star
    
       //set current star
        WebUtilities.CurrentStar = itm
    
        //go to tweet vc
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var newVC = mainStoryboard.instantiateViewControllerWithIdentifier("TwitterVC") as!  TwitterVC
        newVC.mytwitterHandle =  "@" + itm.twitteracct

        self.tabBarController?.tabBar.hidden = true
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    
   override func tableView( tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell") as! AcctCell
            // Get the actual height required for the cell
            var height  = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            // Add an extra point to the height to account for the cell separator, which is added between the bottom
            //// of the cell's contentView and the bottom of the table view cell.
            height += 1.0
            return height < 50.0 ? 50.0 : height
    }

    func cancel() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(WebUtilities.Constants.Entity_Star, inManagedObjectContext: context)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "twitteracct", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {

            let msgs = "Unresolved error \(error!), \(error!.userInfo)"
            Utilities.showAlert(self, title: "ERROR", message:  msgs)
        }
        
        
        return _fetchedResultsController!
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
         
        case .Update:
             let tweetAcct = self.fetchedResultsController.objectAtIndexPath(indexPath!) as! Star
             self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! AcctCell, tweetAcct: tweetAcct)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
 
        // if all data deleted, reset the tab index
       
        if( self.fetchedResultsController.fetchedObjects?.count == 0){
            // exit Edit mode
            setEditing(false ,animated: true)
            self.navigationItem.leftBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem?.enabled = false
            
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            var tababarController = appDelegate.window!.rootViewController as! UITabBarController
            tababarController.selectedIndex = 1
        }
    }

    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
 
            // remove from nsdefaults
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Star
            Utilities.deleteDatatoDefaults(object.twitteracct)
            Utilities.deleteDatatoDefaults( WebUtilities.Constants.TwitterLastUpdated + object.twitteracct)
  
            //remove from DB
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

            //remove images
            var imageURL = split( object.photoUrl) {$0 == "/"}
            WebUtilities.Caches.imageCache.removeImagefromDevice(imageURL.last!)
            
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                Utilities.showAlert(self, title: "Fatal Error", message: "\(error!.userInfo)")
                
                abort()
            }
        }
    }
}

