//
//  Helper.swift
//  TwitterAnalysis
//
//
//  Created by Jeffrey Zhang on 4/26/15.
//  Copyright (c) 2015   All rights reserved.
//

import UIKit
import Social
import Accounts
import CoreData


// MARK: - Convenient Resource Methods

extension WebUtilities {
    
    
    //return StarHolder in memory
    func getTwitterUser( who: UIViewController, mytwitterHandle: String,
                        completionHandler: (result: StarHolder?, error: NSError?) -> Void)   {
            
            let account = ACAccountStore()
            let accountType = account.accountTypeWithAccountTypeIdentifier(
                ACAccountTypeIdentifierTwitter)
            
            account.requestAccessToAccountsWithType(accountType, options: nil,
                completion: {(success: Bool, error: NSError!) -> Void in
                    
                    if success {
                        let arrayOfAccounts =
                        account.accountsWithAccountType(accountType)
                        
                        if arrayOfAccounts.count > 0 {
                            let twitterAccount = arrayOfAccounts.last as! ACAccount
                            //prepare to call
                            let requestURL = NSURL(string: UrlPaths.TWITTER_User_URL)
                            
                            var  parameters  = [
                                ParameterKeys.ScreenName : mytwitterHandle,
                            ]
                            let postRequest = SLRequest(forServiceType:  SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.GET,
                                URL: requestURL,
                                parameters: parameters)
                            
                            postRequest.account = twitterAccount
                            
                            postRequest.performRequestWithHandler(
                                {(responseData: NSData!,
                                    urlResponse: NSHTTPURLResponse!,
                                    error: NSError!) -> Void in
                                    var err: NSError?
                                    
                                    if let err = err {
                                        Utilities.showAlert(who, title: "Error", message: "No Connection")
                                        return
                                    }
                                    
                                    let jsonresults = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves, error: &err) as! NSDictionary

                                    
                                    if( jsonresults["errors"] != nil) {

                                        let msgs = jsonresults["errors"]  as!  NSArray
                                        let msg  = msgs[0].objectForKey("message") as! String
                                        Utilities.showAlert(who, title: "Error", message: msg)
                                        return
                                    }
                                    if jsonresults.count != 0{
                                        
                                        let photoUrl = jsonresults[JSONResponseKeys.Photo] as! String
                                        let followers = toString(jsonresults[JSONResponseKeys.FollowersCount]!).toInt()!
                                        let acct = jsonresults[JSONResponseKeys.ScreenName] as! String
                                        
                                        ///find it first if there, return the object and then update as needed
                                        // instead of creating a new one always!!
                                        let dict = ["twitteracct":acct]
                                        let obj =  CoreDataManager.sharedInstance().searchStoredObject(WebUtilities.Constants.Entity_Star, searchNameValue: dict)
                                
                                        if  let obj = obj as? Star {
                                            let starholder =  StarHolder(twitteracct: mytwitterHandle, followersCount: followers, photoUrl: photoUrl)
                                             completionHandler(result: starholder, error: nil)
                                        }else{
                                            
                                            let result = StarHolder(twitteracct: acct, followersCount: followers, photoUrl: photoUrl)
                                            completionHandler(result: result, error: nil)
                                        }
                                    
                                    } else {
                                        Utilities.showAlert(who, title: "Error", message: "No tweets found!")
                                    }
                            })
                        }else{
                            Utilities.showAlert(who, title: "Error", message: "Cmd-Shift-H (Home Button in ios Simulator) and login twitter account in Settings")
                        }
                    } else {
                        
                        Utilities.showAlert(who, title: "Error", message: "You need allow this app to access your account on device!")
                    }
            })
    }

     

    func getTimeLine(  mytwitterHandle: String, since_id: String, completionhandler:  (error :NSError?) -> Void)   {
    
            let context = CoreDataManager.sharedInstance().managedObjectContext!
            
            let entityDescription =  NSEntityDescription.entityForName(WebUtilities.Constants.Entity_Tweet,  inManagedObjectContext: context)
            var tweet = Tweet(entity: entityDescription!, insertIntoManagedObjectContext: context)
           
            var  parameters  = [
                ParameterKeys.ScreenName : mytwitterHandle,
                ParameterKeys.IncludeRTS : "0",
                ParameterKeys.TrimUser : "1",
                ParameterKeys.Count: toString(Constants.MaxTweetsCount)
            ]
            
            if( since_id != "0"){
                parameters[ParameterKeys.SinceID] = since_id
            }
            
        
            TwitterRequest(UrlPaths.TWITTER_TimeLine_URL, parameters: parameters) {
                        (results, error ) in
                
                            if let err = error {
                                completionhandler(error: err)
                                return
                            }
                        
                            var id = ( since_id  as NSString).longLongValue
                
                            if results.count != 0 {
                                //insert into DB Store
                                for result in results as! [AnyObject] {
                                    let rtwCt =  toString(result.objectForKey(JSONResponseKeys.TweetRetweets)!).toInt()!
                                    let likes =  toString(result.objectForKey(JSONResponseKeys.TweetLikes)!).toInt()!
                                    let createdAt = toString(result.objectForKey(JSONResponseKeys.TweetCreatedAt)!)
                                    let id_str = toString(result.objectForKey(JSONResponseKeys.TweetID)!)
                                    let txt = result.objectForKey(JSONResponseKeys.TweetText) as! String
                                    
                                    let id_new =  (result.objectForKey(JSONResponseKeys.TweetID) as! NSString).longLongValue
                                    if(id_new > id) {
                                        id = id_new
                                    }
                                    // insert tweet to context
                                    let  mytweet = Tweet(createdAt: createdAt, id_str: id_str, text: txt, like: likes, retweet: rtwCt)
                                 }
               
                                //save  since_id
                                Utilities.saveDatatoDefaults(mytwitterHandle, value: toString(id))

                                //save to DB
                                CoreDataManager.sharedInstance().saveContext()
                               
                                completionhandler(error: nil)
                                
                                
                            } else {
                                let userInfo = [NSLocalizedDescriptionKey : "No tweets found!"]
                                let error =  NSError(domain: Constants.DOMAIN_NAME, code: 9, userInfo: userInfo)
                                completionhandler(error: nil)
                            }
                        }
    }
}