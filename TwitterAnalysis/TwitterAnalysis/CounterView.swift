//  CounterView.swift
//  
//  TwitterAnalysis
//
//  Show ranking graphically...#1 will on the right side
//  with a medal for top 5 tweets based on retweets
//
//  This is based on 
//  http://www.raywenderlich.com/90695/modern-core-graphics-with-swift-part-3
// Jeffrey Zhang
// 4/25/2015


import UIKit

var NoOfTweets: Int = 8  // default initial value at deasign
let π:CGFloat = CGFloat(M_PI)

@IBDesignable class CounterView: UIView {
  
  @IBInspectable var counter: Int = 5 { //  is the default at design
    didSet {
      if counter <=  NoOfTweets {
        //the view needs to be refreshed
        setNeedsDisplay()
      }
    }
  }
  @IBInspectable var outlineColor: UIColor = UIColor.greenColor()
  @IBInspectable var counterColor: UIColor = UIColor.orangeColor()
  
  override func drawRect(rect: CGRect) {
    
     NoOfTweets =  WebUtilities.Alltweets.count
    // 1
    let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
    
    // 2
    let radius: CGFloat = max(bounds.width, bounds.height)
    
    // 3
    let arcWidth: CGFloat = 76
    
    // 4: clockwise
    let startAngle: CGFloat = 3 * π / 4
    let endAngle: CGFloat = π / 4
    
    // 5
    var path = UIBezierPath(arcCenter: center,
                          radius: radius/2 - arcWidth/2,
                          startAngle: startAngle,
                          endAngle: endAngle,
                          clockwise: true)
    
    // 6
    path.lineWidth = arcWidth
    counterColor.setStroke()
    path.stroke()
    
    
    //Draw the outline
    
    //1 - first calculate the difference between the two angles
 
    let angleDifference: CGFloat = 2 * π - startAngle + endAngle
    
    //then calculate the arc for each single glass
    let arcLengthPerTweet = angleDifference / CGFloat(NoOfTweets)
    
    //then multiply out by the actual tweets...revserse order

    let outlineEndAngle = arcLengthPerTweet * CGFloat(NoOfTweets - counter + 1) + startAngle
    
    
    //2 - draw the outer arc
     var outlinePath = UIBezierPath(arcCenter: center,
                        radius: bounds.width/2 - 2.5,
                        startAngle: outlineEndAngle,
                        endAngle: endAngle,
                        clockwise: true)
    
    //3 - draw the inner arc
    outlinePath.addArcWithCenter(center,
        radius: bounds.width/2 - arcWidth + 2.5,
        startAngle: endAngle,
        endAngle: outlineEndAngle,
        clockwise: false)
 
    
    //4 - close the path
    outlinePath.closePath()
    
    outlineColor.setStroke()
    outlinePath.lineWidth = 5.0
    outlinePath.stroke()

    // now done with ranking (FAN shape)
    
    
    //Counter View markers
    
    let context = UIGraphicsGetCurrentContext()
    
    //1 - save original state
    CGContextSaveGState(context)
    outlineColor.setFill()
    
    let markerWidth:CGFloat = 5.0
    let markerSize:CGFloat = 10.0
    
    //2 - the marker rectangle positioned at the top left
    var markerPath = UIBezierPath(rect:
                  CGRect(x: -markerWidth/2,
                    y: 0,
                    width: markerWidth,
                    height: markerSize))
    
    //3 - move top left of context to the previous center position
    CGContextTranslateCTM(context,
                      rect.width/2,
                      rect.height/2)
    
    for i in 1...NoOfTweets {
      //4 - save the centred context
      CGContextSaveGState(context)
      
      //5 - calculate the rotation angle
      var angle = arcLengthPerTweet * CGFloat(i) + startAngle - π/2
      
      //rotate and translate
      CGContextRotateCTM(context, angle)
      CGContextTranslateCTM(context,
                                0,
                                rect.height/2 - markerSize)
      
      //6 - fill the marker rectangle
      markerPath.fill()
      
      //7 - restore the centred context for the next rotate
      CGContextRestoreGState(context)
    }
    
    //8 - restore the original state in case of more painting
    CGContextRestoreGState(context)
  }
}
