//
//  Tweet.swift
//  TwitterAnalysis
//
//
//
//   twitter field data type
//   https://dev.twitter.com/overview/api/tweets
//
//
//  Created by Jeffrey Zhang on 4/24/15.
//  Copyright (c) 2015  All rights reserved.
//

import Foundation
import CoreData

class Tweet: NSManagedObject {
    
    @NSManaged var createdAt: String!
    @NSManaged var id_str: String!
    @NSManaged var likes: NSNumber
    @NSManaged var retweets: NSNumber
    @NSManaged var text: String
    @NSManaged var star: Star!
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    // MARK: initialization of Pin with  lat and longi
    
    init( createdAt : String, id_str: String, text: String, like: Int, retweet: Int) {
        // Core Data
        let context = CoreDataManager.sharedInstance().managedObjectContext!
        let entity =  NSEntityDescription.entityForName(WebUtilities.Constants.Entity_Tweet, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
         
        self.createdAt = createdAt
        self.id_str = id_str
        self.text = text
        self.likes = like
        self.retweets = retweet
        self.star = WebUtilities.CurrentStar
        
    }
}
