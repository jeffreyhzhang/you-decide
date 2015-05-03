//
//  ReadMeVC.swift
//  TwitterAnalysis
//
//  Created by JeffreyLee on 5/3/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit

class  ReadMeVC:  UIViewController, UITextViewDelegate {
    var textView: UITextView!
    var textStorage: SyntaxHighlightTextStorage!
    var mytext: String = "OVERVIEW \r\n\n You need setup twitter account on the device first before you can run this app. Cmd+Shift+H to get to home screen of iOS simulator. Go to Settings, Find Twitter and enter user name and password and Click Login.\n\r1. Search twitter account, and show # of followers with last updated timestamp.\r2. Add twitter account to list if user selects the just found twitter account. Invalid accout will be alerted to user. All added twitter accounta are listed in alphabetically reverse order.\r3. Display all the tweets (up to maximum predefined) once the twitter account is selected .\r4. View the trending of the twitter account's retweets over time graphically once the tweet is selected (Trending tab). \r5. Rank each tweet graphically. If ranked very high, a golden medal is awarded (Ranking tab).\r6. Delete the twitter account if user no longer follows the twitter account. \r7. Refresh  all the twitter accounts as the number of followers may changed since added/refreshed last time. \nExample: Katy Perry (twitter handle is katyperry with about 70 million followers) and Taylor Swift (tayloyswift13 is the twitter handler with about 57 million followers).\r8. ReadMe tab shows overview of the app.\r\r\rTECHINCAL OVERVIEW\r\r1. When the app starts for the 1st time, user will be presented with search tab where user can search for twitter account. User will be alerted  if the account already in existing list or there is no network connectivity. \nSubsequently, when use starts the app, the available twitter accounts added before will be listed in a table. \nTechnical details: I use NSKeyedArchiver to store total number of twitter accounts for this app. This tells the app which tab to go to when the app starts. When there is no twitter accounts, the edit and refresh button one the top navigationbar will be disabled.\r2. When user select the twitter account found after search, the twitter account is stored in sqliteDB under Document folder for the device, the lastupdated timestamp for this twitter account is stored in NSUserDefaults under Preferences folder for the device. \r3. I use CoreData to store Twiiter account and Tweets entities. The rleationship is one (twitter account) to many (tweets), I also set the delete rules as cascading delete, so when twitter account is deleted, all tweets associated with it are deleted. \r4. When user choose to remove a twitter account by tap Edit on the top left corner of the navigationbar. The data stored in sqlteDB, as well as NSDafault are deleted, the image downloaded is also deleted. Once all accounts are deleted, user will be automatically presented with twitter Search screen."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTextView()
        textView.scrollEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        textStorage.update()
    }
    
    
    override func viewDidLayoutSubviews() {
        //textView.frame = view.bounds
        textView.frame = CGRectMake(0, 70, view.bounds.width, view.bounds.height - 70.0 )
    }
    
    
    func createTextView() {
        // 1. Create the text storage that backs the editor
       // let attrs = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        let attrs = [NSFontAttributeName: UIFont(name: "Georgia", size: 10.0)!]
        let attrString = NSAttributedString(string: mytext, attributes: attrs)
        textStorage = SyntaxHighlightTextStorage()
        textStorage.appendAttributedString(attrString)
        
        let newTextViewRect = view.bounds
        
        // 2. Create the layout manager
        let layoutManager = NSLayoutManager()
        
        // 3. Create a text container
        let containerSize = CGSize(width: newTextViewRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        // 4. Create a UITextView
        textView = UITextView(frame: newTextViewRect, textContainer: container)
        textView.delegate = self
        view.addSubview(textView)
    }
    
}
