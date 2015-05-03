//
//  AppDelegate.swift
//  TwitterAnalysis
//
//  Created by JeffreyLee on 4/27/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
     
     
        // since the default rootViewController is  tabcontroller 
        // if no  twitter accts yet, we will shoe new account tab ( index = 1) and hide nav bar at top
        if(Utilities.getDatafromNSKey()  == 0 ) {
            var tababarController = self.window!.rootViewController as! UITabBarController
            tababarController.selectedIndex = 1
        }
        
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        CoreDataManager.sharedInstance().saveContext()
        
        //save keyarchive too
    }

}

