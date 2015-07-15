//
//  Networking.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 14/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import Alamofire
import CoreData
import Foundation

class Networking {
    class func getPeople(context : NSManagedObjectContext) -> Void {
        Alamofire.request(Router.People())
            .responseString(encoding: NSUTF8StringEncoding)
                { (request : NSURLRequest?, response : NSHTTPURLResponse?, data : String?, error : NSError?) -> Void in
                // Do something
                    if let range = data?.rangeOfString("var people = ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: NSLocale.currentLocale()) {
                        var jsonString = data?.substringFromIndex(range.endIndex)
                        jsonString = jsonString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        jsonString = jsonString?.substringToIndex(jsonString!.endIndex.predecessor())
                        if let jsonData = jsonString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            var jsonResult : [NSDictionary] = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as! [NSDictionary]
                            
                            let dataManager = DataManager(context: context)
                            dataManager.peopleFromDictionary(jsonResult)
                            
                        } else {
                            // TODO Error
                        }
                    }
                    
                    // TODO Error
        }
    }
    
    class func getProgram(context : NSManagedObjectContext) -> Void {
        Alamofire.request(Router.Program())
            .responseString(encoding: NSUTF8StringEncoding)
                { (request : NSURLRequest?, response : NSHTTPURLResponse?, data : String?, error : NSError?) -> Void in
                    if let range = data?.rangeOfString("var program = ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: NSLocale.currentLocale()) {
                        var jsonString = data?.substringFromIndex(range.endIndex)
                        jsonString = jsonString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        jsonString = jsonString?.substringToIndex(jsonString!.endIndex.predecessor())
                        if let jsonData = jsonString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            var error : NSError?
                            let jsonResult : [NSDictionary] = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
                            
                            let dataManager = DataManager(context: context)
                            dataManager.programFromDictionary(jsonResult)
                        }
                    }
        }
    }
    
    enum Router : URLRequestConvertible {
        static let baseUrlString = "https://nineworlds.co.uk/sites/nineworlds.co.uk/2015-schedule/data"
        
        case People()
        case Program()
        
        var path : String {
            switch self {
            case .People:
                return "people.js"
            case .Program:
                return "program.js"
            }
        }
        
        var URLRequest: NSURLRequest {
            let url = NSURL(string: Router.baseUrlString)!
            let urlRequest = NSMutableURLRequest(URL: url.URLByAppendingPathComponent(path))
            urlRequest.HTTPMethod = "GET"
            
            return urlRequest
        }
    }
}