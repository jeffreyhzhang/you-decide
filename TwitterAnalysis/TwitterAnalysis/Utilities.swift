//
//  Utilities.swift
//
//  TwitterAnalysis
//
//
//  I put some common utility func here so every viewcontroller can use
//
//
//  Basedon my OnTheMap Projetcs
//
//  Created by Jeffrey Zhang on 3/28/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit;
import SystemConfiguration


struct TwitterState{
    
    let twitterhandle: String
    let since_id: String
    
    
    init( twitterhandle: String, since_id :String ){
        self.twitterhandle = twitterhandle
        self.since_id = since_id
    }
}


public class Utilities {
    
   
    static var dataFilePath: String?
    
    //generic alert...with callback function when OK'd
    class func showAlert( who : UIViewController, title: String, message : String) {
        let myAlert = UIAlertController()
        myAlert.title = title
        myAlert.message = message
        
        let myaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(myaction)
        who.presentViewController(myAlert, animated:true , completion:nil)
    }
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
    // another way to check...try to get to google.com
    // since google is the most reliable site there is
    // if you cannot get to it...then network issue.
    //
    class func isNetworkAvialable(urlforTest: String?)->Bool{
        
        var Status:Bool = false
        var myurl =  urlforTest!.isEmpty ? "http://google.com/" : urlforTest!
        let url = NSURL(string: myurl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
    
    class func AutoSizeLabelField(lblField: UILabel, minScaleFactor : CGFloat) {
        //auto shrink to fit label
        lblField.minimumScaleFactor = minScaleFactor
        lblField.adjustsFontSizeToFitWidth = true
        lblField.setNeedsLayout()
        lblField.layoutIfNeeded()
    }
    
    // this is stored under Document folder for specific device....e.g. for iPhone6
    //~Library/Developer/CoreSimulator/Devices/B965D2A0-97F8-411D-ADB3-921DDCA9D058/data/Containers/Data/Application/9ED1CCA2-35FA-4A3B-B169-DCC0FDB6505D/Document
    class func getDatafromNSKey() -> Int {
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,  .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as! String
        dataFilePath =  docsDir.stringByAppendingPathComponent(WebUtilities.Constants.NSKey_FileNmae)
println(dataFilePath)
        if filemgr.fileExistsAtPath(dataFilePath!) {
            let NumberofAccts =  NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!)  as!  Int
            return NumberofAccts
        }
        return 0
    }
    
    //save.....overwrite ...so only one entry
    class func saveDatatoNSKey(NumberofAccts: Int){
        NSKeyedArchiver.archiveRootObject(NumberofAccts  , toFile: dataFilePath!)
    }
    
    //
    // this is stored under Preferences folder for specific device....e.g.
    //~Library/Developer/CoreSimulator/Devices/B965D2A0-97F8-411D-ADB3-921DDCA9D058/data/Containers/Data/Application/9ED1CCA2-35FA-4A3B-B169-DCC0FDB6505D/Preferences
    
    //case sensitive...so allways  use lowercase when store and retrieve
    //
    class func getDatafromDefaults( key : String) -> String
    {
       let lkey =   key.lowercaseString
       return NSUserDefaults.standardUserDefaults().stringForKey(lkey) ?? "0"
    }
    class func saveDatatoDefaults(key: String, value :String){
          let lkey =   key.lowercaseString
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: lkey)
   }
    //removeObjectForKey
    class func deleteDatatoDefaults(key: String ){
        let lkey =   key.lowercaseString
        NSUserDefaults.standardUserDefaults().removeObjectForKey(lkey)
    }
    
   class  func  NowSTimestamp() ->String{
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(NSDate())
    }
}