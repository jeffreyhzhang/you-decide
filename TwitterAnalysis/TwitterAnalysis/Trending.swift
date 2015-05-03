//
//  Trending.swift
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

class TrendingVC: UIViewController {
    
    
    //Label outlets
    @IBOutlet weak var AvgTweet: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var currentTweetInfo: UILabel!
    @IBOutlet weak var currentTweetText: UITextView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTweetInfo.text = toString( WebUtilities.CurrentTweet!.retweets) + " reteets"
        currentTweetText.text = WebUtilities.CurrentTweet!.text
        setupGraphDisplay()
         
        graphView.becomeFirstResponder()
    }
    
 
    func setupGraphDisplay() {

        graphView.graphPoints = getGraphPoints()
        
        //2 - indicate that the graph needs to be redrawn
        graphView.setNeedsDisplay()

        if(graphView.graphPoints.count < 1 ){
            println("Should never happend!")
            return
        }
        maxLabel.text = "\(maxElement(graphView.graphPoints))"
        minLabel.text = "\(minElement(graphView.graphPoints))"

        //3 - calculate average from graphPoints
        let average = graphView.graphPoints.reduce(0, combine: +) / graphView.graphPoints.count
        AvgTweet.text = "\(average)"
        
        
        
        let dateFormatter = NSDateFormatter()
        let days = getGraphDates()
        
        //5 - set up the axis label....total 2 ( tag 1--2) labels predefined
        //    all label fixed on chart CoreGraphics not easy to manipulate
        //
        for i in reverse(1...days.count) {
            if let labelView = graphView.viewWithTag(i) as? UILabel {
                labelView.text = days[i-1]
            }
        }
        
    }
    
    //  MARK : return all retweets over time  in reverse order or display from old to latest date
    
    func getGraphPoints() -> [Int]{
        
        var dataArray =  [Int]()
        
        if(WebUtilities.Alltweets.count > 0){
            for tweet in WebUtilities.Alltweets {
                // tweet.likes
 
                let retweets = toString(tweet.retweets).toInt()!
                dataArray.append(retweets)  //(tweet.retweets as Int)
            }
        }
        return dataArray.reverse()
    }
    
    // MARK :
    //
    // theer are many data-points with too many dates
    // there is no need to shoow every single date...and sometimes, many tweets per day.
    // all I need is the oldest and latest tweet date
    func getGraphDates() -> [String]{
        
        var dateArray =  [String]()
        
        //latest date is last in array===> reversed
        
        let tweetsCt = WebUtilities.Alltweets.count
        var oldestTweetDate: NSDate = NSDate().dateByAddingTimeInterval(-90 * 24 * 60 * 60)  //go back 90 days
        var latestTweetDate: NSDate = oldestTweetDate
        let formatter = NSDateFormatter()
        if(tweetsCt > 0){
            //twitter date format
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            //get the latest tweet date
            var tweedate: NSDate = formatter.dateFromString(WebUtilities.Alltweets[0].createdAt)!
            /*
            if( tweedate.compare(latestTweetDate) == NSComparisonResult.OrderedDescending ) {
            latestTweetDate = tweedate
            }
            */
            latestTweetDate = tweedate.laterDate(latestTweetDate)
            //get the oldest tweet date ( up to 90 days)
            tweedate = formatter.dateFromString(WebUtilities.Alltweets[tweetsCt - 1].createdAt)!
            /*
            if( tweedate.compare(oldestTweetDate) == NSComparisonResult.OrderedAscending ) {
            oldestTweetDate = tweedate
            }
            */
            oldestTweetDate = tweedate.earlierDate(oldestTweetDate)
            
            let usDateFormat = NSDateFormatter.dateFormatFromTemplate("MMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "en-US"))
            formatter.dateFormat = usDateFormat
            
            dateArray.append(formatter.stringFromDate(oldestTweetDate))
            dateArray.append(formatter.stringFromDate(latestTweetDate))
        }
        return dateArray
    }
}

