//
//  RankingVC.swift
//  TwitterAnalysis
//
//  Jeffrey Zhang
//
//  This is based on Caroline Begbie's work
//  http://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1
//  Copyright (c) 2015  . All rights reserved.
//

import UIKit
import Foundation

class RankingVC: UIViewController {
    
 
    var CurrentTweetRanking : Int = 0
    
    @IBOutlet weak var medalView: MedalView!
    
    //Label outlets
    @IBOutlet weak var AvgTweet: UILabel!
    @IBOutlet weak var currentTweetInfo: UILabel!
    @IBOutlet weak var currentTweetText: UITextView!
    @IBOutlet weak var containerView: UIView!
    
    //Counter outlets
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentTweetRanking = WebUtilities.Alltweets.count
 
        let myVal : Int = WebUtilities.CurrentTweet!.retweets as! Int
        
        for itm in  WebUtilities.Alltweets   {
            let val = itm.retweets as! Int
            if( val < myVal) {
                CurrentTweetRanking -= 1
            }
        }
        
        //this shows ranking #
        counterLabel.text = String(CurrentTweetRanking)
        
        currentTweetInfo.text = "\(myVal) reteets and ranked #\(CurrentTweetRanking)"
        currentTweetText.text = WebUtilities.CurrentTweet!.text
        
        //ranking
        counterView.counter  = CurrentTweetRanking
        
        //show medal if top :MinToHaveMedal
        showMedal()
    }
    
    // medal is shown for top MinToHaveMedal in terms of retweets
    func showMedal() {
        if CurrentTweetRanking <= WebUtilities.Constants.MinToHaveMedal {
            medalView.showMedal(true, myRank: CurrentTweetRanking)
        } else {
            medalView.showMedal(false, myRank: CurrentTweetRanking)
        }
    }

}


