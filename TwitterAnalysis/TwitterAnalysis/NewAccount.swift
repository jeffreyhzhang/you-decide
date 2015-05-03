//
//  NewAccount.swift
//  TwitterAnalysis
//
//  Created by JeffreyLee on 5/1/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//


//

import Foundation
import UIKit
import CoreData

class NewAccount: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var acctTableView: UITableView!
    @IBOutlet weak var acctSearchBar: UISearchBar!
    var FoundMatch: Bool = false
    var tweetAcct: StarHolder?
    var imgHolder:UIImage!
    
    @IBOutlet weak var ShowDelay: UIActivityIndicatorView!
    
    
    // The most recent data download task. We keep a reference to it so that it can
    // be canceled
    var searchTask: NSURLSessionDataTask?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
       lblReminder.text = "Search by twitter account like katyperry or taylorswift13"
       lblReminder.alpha = 1
       lblReminder.font = UIFont.boldSystemFontOfSize(10)
       Utilities.AutoSizeLabelField(lblReminder, minScaleFactor: 0.3)
    
        
        //check network
        if(!Utilities.isConnectedToNetwork()){
            Utilities.showAlert(self, title: "Error", message: "Network service not available!")
            return
        }
        
        
        /* Configure tap recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        // let user know what to do
        acctSearchBar.text = WebUtilities.Constants.KatyPerry
        acctSearchBar.delegate = self
        
        // use image from assets as imgplaceholder
        imgHolder = UIImage(named: "trending")
        
        // hide
        ShowDelay.alpha =  0
        ShowDelay.userInteractionEnabled = false
        ShowDelay.center = self.view.center;
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    
    // MARK: - Dismiss Keyboard
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.acctSearchBar.isFirstResponder()
    }
    
    func doSearch() {
        
        /* Cancel the last task */
        if let task = searchTask {
            task.cancel()
        }
        
        let searchText = acctSearchBar.text
        
        /* If the text is empty we are done */
        if searchText == "" {
            acctTableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        
        ShowDelay.alpha = 1
        ShowDelay.startAnimating()
        

        /* FIX: Replace spaces with '+' */
        var twitterhandle = searchText.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!.lowercaseString
        let dict = ["twitteracct":twitterhandle]
        let obj =  CoreDataManager.sharedInstance().searchStoredObject(WebUtilities.Constants.Entity_Star, searchNameValue: dict)
        
        /* already in the table ...account case senitive*/
        if ( obj != nil ) {
            ShowDelay.alpha = 0
            ShowDelay.stopAnimating()

            Utilities.showAlert(self, title: "Alert", message: "Twiiter account Already in the list")
            return
        }
        /* get twitter user */
        WebUtilities.sharedInstance().getTwitterUser(self, mytwitterHandle: twitterhandle, completionHandler: { (star, error) -> Void in
            if(error != nil){
                println( error)
            }
            if  star != nil {
                self.FoundMatch = true
                self.tweetAcct =  star

                // refresh table
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.ShowDelay.alpha = 0
                    self.ShowDelay.stopAnimating()
                    
                    self.lblReminder.alpha = 0
                    self.acctTableView.reloadData()
                }
            }
        })
       acctSearchBar.resignFirstResponder()
    }
    
 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    
     // MARK: - UISearchBarDelegate

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        acctSearchBar.text = ""
        return true
    }
    

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //we can do  search here too  instead of buttonclick below
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
       //do the search
        doSearch()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! UITableViewCell
        
        cell.imageView?.image = imgHolder
        cell.textLabel!.text =  tweetAcct!.twitteracct
        cell.detailTextLabel!.font =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 12)!
        cell.detailTextLabel!.text = toString(tweetAcct!.followersCount)
        
       //download image
        ShowDelay.alpha = 1
        ShowDelay.startAnimating()
       
        WebUtilities.sharedInstance().downloadImg(tweetAcct!.photoUrl, completionHandler: { (img) -> Void in
            //save to disk and cache
            var imageURL = split( self.tweetAcct!.photoUrl) {$0 == "/"}
            WebUtilities.Caches.imageCache.storeImage(img, withIdentifier: imageURL.last!)
       
            dispatch_async(dispatch_get_main_queue()) {
                cell.imageView?.image = img
                self.ShowDelay.alpha = 0
                self.ShowDelay.stopAnimating()
            }
        })
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FoundMatch ? 1 : 0
    }
    
    //once selected, we create manged Str from memory and add to DB
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //set current star
        
        let TWAcct = tweetAcct!.twitteracct
        let TWFollers = toString(tweetAcct!.followersCount).toInt()!
        let TWImgUrl = tweetAcct!.photoUrl
        WebUtilities.CurrentStar = Star(twitteracct: TWAcct, followersCount: TWFollers, photoUrl: TWImgUrl)
        
        //save to DB before I leave
        
        CoreDataManager.sharedInstance().saveContext()

        
        //save to NSDefault: lastupdate timestamp
        
        let mylastupdateKey = WebUtilities.Constants.TwitterLastUpdated + tweetAcct!.twitteracct
        Utilities.saveDatatoDefaults(mylastupdateKey, value: Utilities.NowSTimestamp())

        
        // remove data from search
        
        FoundMatch = false
        acctSearchBar.text = "Search by twitter account"
        self.acctTableView.reloadData()
        
        
        //switch tab

        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        var tababarController = appDelegate.window!.rootViewController as! UITabBarController
        tababarController.selectedIndex = 0
    
    }
    
    
    func cancel() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

