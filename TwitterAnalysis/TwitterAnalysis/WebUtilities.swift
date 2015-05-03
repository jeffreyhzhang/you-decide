//
//  WebUtilities.swift
//  TwitterAnalysis
//
//  From My previous project OneTheMap and/or VirtualTourist
//

import UIKit
import Social
import Accounts
import CoreData


class WebUtilities : NSObject {
    
    /* Shared session */
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* this is current active star we are looking at...all tweets in the VC*/
    static var CurrentStar: Star?
    static var CurrentTweet: Tweet?
    static var Alltweets: [Tweet]!

    // MARK:

    
    func TwitterRequest( urlpath: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void){
    
     
        var urlString = urlpath
        
        let url = NSURL(string: urlString)!
    
    
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
                completion: {(success: Bool, error: NSError!) -> Void in
        
        if success {
                        let arrayOfAccounts =
                        account.accountsWithAccountType(accountType)
                        
                        if arrayOfAccounts.count > 0 {
                            let twitterAccount = arrayOfAccounts.last as! ACAccount
                            let request = SLRequest(forServiceType:  SLServiceTypeTwitter,
                                                        requestMethod: SLRequestMethod.GET,
                                                        URL: url,
                                                        parameters: parameters)
                            
                            request.account = twitterAccount
                            
                            request.performRequestWithHandler(
                                {(responseData: NSData!,   urlResponse: NSHTTPURLResponse!,  error: NSError!) -> Void in
                                      /* 5/6. Parse the data and use the data (happens in completion handler) */
                                    if let error = error {
                                        let newError = WebUtilities.errorForData(responseData, response: urlResponse, error: error)
                                        completionHandler(result: nil, error: error)
                                    } else {

                                        var parsingError: NSError? = nil
                                        //Could not authenticate you.
                                        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves, error: &parsingError)
                                        
                                        WebUtilities.parseJSONWithCompletionHandler(responseData, completionHandler: completionHandler)
                                    }
                            })
                        }else{
                            let userInfo = [NSLocalizedDescriptionKey : "Cmd-Shift-H (Home Button in ios Simulator) and login twitter account in Settings"]
                            let error =  NSError(domain: Constants.DOMAIN_NAME, code: 1, userInfo: userInfo)
                            completionHandler(result: nil, error: error)
            }
        }else{
            let userInfo = [NSLocalizedDescriptionKey : "Cmd-Shift-H (Home Button in ios Simulator) and login twitter account in Settings"]
            let error =  NSError(domain: Constants.DOMAIN_NAME, code: 1, userInfo: userInfo)
            completionHandler(result: nil, error: error)
       }
                    
    })
}
    
    /*  VaildateURL */
    
    func ValidateURL( urlpath: String,  completionHandler: (success: Bool, error: NSError?) -> Void)  {
        
        let url = NSURL(string: urlpath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "Head"
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = WebUtilities.errorForData(data, response: response, error: error)
                
                completionHandler(success:  false, error: newError)
            } else {
                var parsingError: NSError? = nil
                
                // URL Responded - Check Status Code
                if let urlResponse = response as? NSHTTPURLResponse
                {
                    if ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400) || urlResponse.statusCode == 405)
                        // 200-399 = Valid Responses, 405 = Valid Response (Weird Response on some valid URLs)
                    {
                        println(urlResponse.statusCode)
                        completionHandler(success: true, error: nil)
                        // if valid, we caontinue
                        dispatch_async(dispatch_get_main_queue()) {
                            
                        }
                    }
                    else // Error
                    {
                        completionHandler(success: false, error: nil)
                    }
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    
    // MARK: - Helpers
    // These functions are class level function or type method that are not tied to specifuc instances
    // like sticit method in struct...you can you it without an instacnes of the class as object!
    //
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: nil) as? [String : AnyObject] {
      
             /*
            [errors: (
            {
            code = 32;
            message = "Could not authenticate you.";
            }
            )]
           */
            
            if let itm = parsedResult["errors"] as? NSArray {
                let errorMessage = itm[0]["message"] as! String
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                                
                return NSError(domain: Constants.DOMAIN_NAME, code: 99, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            // let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    //
    // why not just return WebUtilities() directly?
    //
    class func sharedInstance() -> WebUtilities {
        
        struct Singleton {
            static var sharedInstance = WebUtilities()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    //save image in background.... no need callback
    func saveImage(imageUrlString: String) {
        
        let url = NSURL(string: imageUrlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let img = UIImage(data: data) {
                var imageURL = split(imageUrlString) {$0 == "/"}
                WebUtilities.Caches.imageCache.storeImage(img, withIdentifier: imageURL.last!)
            }
        }
        task.resume()
    }
    
    // MARK : get image from URL....if nil, should re-download and save
    func getImg(imageUrlString: String,  completionHandler: (img: UIImage?)   -> Void) {
        if ( !imageUrlString.isEmpty) {
            
             var imageURL = split(imageUrlString) {$0 == "/"}
            
            let img = WebUtilities.Caches.imageCache.imageWithIdentifier(imageURL.last!)
            if(img == nil) {
                //should try again to download...
                //maybe still downloading/saving to disk, maybe no network connectivity
                downloadImg(imageUrlString){ img in
                    
                    WebUtilities.Caches.imageCache.storeImage(img, withIdentifier: imageURL.last!)

                    completionHandler(img: img)
                }
                return
            }
            completionHandler(img: img)
        }
    }
    
    
    func downloadImg(imageUrlString: String,  completionHandler: (img: UIImage!)   -> Void) {
        let url = NSURL(string: imageUrlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            let img = UIImage(data: data)
            
            completionHandler(img: img)
        }
        
        /* 7. Start the request */
        task.resume()
    }

}
