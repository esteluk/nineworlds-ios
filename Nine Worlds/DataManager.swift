//
//  DataManager.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 14/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    var context : NSManagedObjectContext
    static let IMPORT_COMPLETE = "importComplete"
    
    init(context : NSManagedObjectContext) {
        self.context = context
    }
    
    func peopleFromDictionary(people : [NSDictionary]) {
        for dict in people {
            if let person = searchForObjectOtherwiseCreate("Person", id: dict.objectForKey("id")) as? Person {
                person.loadFromDictionary(dict)
            }
        }
        
        importComplete()
    }
    
    func programFromDictionary(program : [NSDictionary]) {
        for dict in program {
            if let p = searchForObjectOtherwiseCreate("Program", id: dict.objectForKey("id")) as? Program {
                p.loadFromDictionary(dict, manager: self)
            }
        }
        
        importComplete()
    }
    
    func importComplete() {
        var error: NSError?
        if context.save(&error) {
            let notification = NSNotification(name: DataManager.IMPORT_COMPLETE, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        
        if error != nil {
            print(error?.localizedDescription)
        }
    }
    
    func searchForObjectOtherwiseCreate(entityName: String, id: AnyObject?) -> AnyObject? {
        let idNumber = (id as! NSString).integerValue
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %d", idNumber)
        
        if let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count > 0 {
                return fetchResults.first
            }
        }
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
    }
    
    func searchByTitleOtherwiseCreate(entityName: String, title: String) -> AnyObject? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        if let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count > 0 {
                return fetchResults.first
            }
        }
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
    }
}