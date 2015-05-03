//
//  StarHolder.swift
//  TwitterAnalysis
//
//  This is a place holder for searching TweerAcct.
//  instead of store in managedobject context, I have it just in memory
//  When it is picked/chosen, then we make it available to managed store.
//  Created by JeffreyLee on 5/1/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation


class StarHolder {
    
     var photoUrl: String!
     var twitteracct: String!
     var followersCount: NSNumber
    
    // MARK: initialization
    
    init( twitteracct : String, followersCount: Int, photoUrl : String ) {
        self.photoUrl = photoUrl
        self.twitteracct = twitteracct
        self.followersCount = followersCount
    }
    
}
