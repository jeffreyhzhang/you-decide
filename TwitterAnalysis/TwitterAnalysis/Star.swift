//
//  Star.swift
//  TwitterAnalysis
//
//
//  Created by Jeffrey Zhang on 4/26/15.
//  Copyright (c) 2015   All rights reserved.
//

import Foundation
import CoreData

class Star: NSManagedObject {
    
    @NSManaged var photoUrl: String!
    @NSManaged var twitteracct: String!
    @NSManaged var followersCount: NSNumber
    @NSManaged var tweets: [Tweet]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?){
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    // MARK: initialization
    
    init( twitteracct : String, followersCount: Int, photoUrl : String ) {
        
        // Core Data
        let context = CoreDataManager.sharedInstance().managedObjectContext!
        let entity =  NSEntityDescription.entityForName(WebUtilities.Constants.Entity_Star, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.photoUrl = photoUrl
        self.twitteracct = twitteracct
        self.followersCount = followersCount

    }

}
