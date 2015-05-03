//
//  AppConstants.swift
//
//  TwitterAnalysis
//
//
//  Created by Jeffrey Zhang
//  Concept based on my OnTheMap project
//
//  Copyright (c) 2015 Jeffrey Zhang. All rights reserved.
//

extension WebUtilities {
    
    // MARK: - Constants
    struct Constants {
        static let MinToHaveMedal = 5    
        static let MaxTweetsCount = 30  // maximum tweets download allowed
        static let TaylorSwift = "taylorswift13"
        static let KatyPerry = "katyperry"
        static let DOMAIN_NAME = "JeffZhangATT"
        static let SQLITE_FILE_NAME = "TwitterAnalysis.sqlite"
        static let NSKey_FileNmae = "TwitterAnalysis.archive"
        static let TwitterLastUpdated = "lastUpdated"
        
        static let ScreenName = "screen_name"
        static let Entity_Star = "Star"
        static let Entity_Tweet = "Tweet"
        static let TwitterCaheName = "twitterlist"
    }
    
    // MARK: - UrlPaths..RESTful svc from twitter
    struct UrlPaths {
        static let TWITTER_TimeLine_URL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        static let TWITTER_User_URL = "https://api.twitter.com/1.1/users/show.json"
    }
    
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let ScreenName = "screen_name"
        static let IncludeRTS = "include_rts"
        static let TrimUser = "trim_user"
        static let Count = "count"
        static let SinceID = "since_id"
    }
    
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "status code"
        
        // MARK:
        static let TweetID = "id_str"
        static let TweetText = "text"
        static let TweetCreatedAt = "created_at"
        static let TweetLikes = "favorite_count"
        static let TweetRetweets = "retweet_count"
        
        //from user
        static let ScreenName = "screen_name"
        static let FollowersCount = "followers_count"
        static let Photo = "profile_image_url"
        
        // this is for holding all results from JSON returned from request
        //static let TweetResults = "tweets"
    }
}
