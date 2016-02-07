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
    
    var context: NSManagedObjectContext
    var dataManager: DataManager
    var queue: dispatch_queue_t
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.dataManager = DataManager(context: context)
        
        queue = dispatch_queue_create("uk.co.nineworlds", DISPATCH_QUEUE_SERIAL)
    }
    
    func loadData() -> Void {
        self.getProgram()
        self.getPeople()
    }
    
    func getPeople() -> Void {
        
        Alamofire.request(Router.People())
            .validate()
            .responseString { response -> Void in
                
                if let data = response.result.value {
                    if let range = data.rangeOfString("var people = ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: NSLocale.currentLocale()) {
                        var jsonString = data.substringFromIndex(range.endIndex)
                        jsonString = jsonString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        jsonString = jsonString.substringToIndex(jsonString.endIndex.predecessor())
                        if let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            var jsonResult : [NSDictionary]
                            do {
                                try jsonResult = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]

                                dispatch_async(self.queue, { () -> Void in
                                    self.dataManager.peopleFromDictionary(jsonResult)
                                })
                            } catch _ as NSError {
                                
                            }
                            
                            
                            
                        } else {
                            // TODO Error
                        }
                    }
                }
            }
    }
    
    func getProgram() -> Void {
        
        Alamofire.request(Router.Program())
            .responseString { response -> Void in
                
                if let data = response.result.value {
                    if let range = data.rangeOfString("var program = ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: NSLocale.currentLocale()) {
                        var jsonString = data.substringFromIndex(range.endIndex)
                        jsonString = jsonString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        jsonString = jsonString.substringToIndex(jsonString.endIndex.predecessor())
                        if let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            
                            dispatch_async(self.queue, { () -> Void in
                                let jsonResult : [NSDictionary]
                                
                                do {
                                    try jsonResult = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                                    
                                    self.dataManager.programFromDictionary(jsonResult)
                                } catch _ as NSError {
                                    
                                }
                            })
                            
                        }
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
        
        var URLRequest: NSMutableURLRequest {
            let url = NSURL(string: Router.baseUrlString)!
            let urlRequest = NSMutableURLRequest(URL: url.URLByAppendingPathComponent(path))
            urlRequest.HTTPMethod = "GET"
            
            return urlRequest
        }
    }
}