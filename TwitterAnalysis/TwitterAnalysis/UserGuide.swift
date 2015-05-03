//
//  UserGuide.swift
//  TwitterAnalysis
//
//  Created by JeffreyLee on 5/3/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit

class UserGuide: UIViewController{
    
    @IBOutlet weak var ProjectDesc: UITextView!
  
    @IBOutlet weak var ReadMe: UITextView!
    
    override func viewDidLoad() {
        // Readme
        ProjectDesc.text = "This app allows users to search twitter accounts and see the trending of the twitter account's retweets graphically over time and rank each tweet graphically. If the tweet is ranked top 3, a golden medal is awarded."
        
    }
}