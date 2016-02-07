//
//  Location.swift
//  
//
//  Created by Nathan Wong on 14/07/2015.
//
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var events: NSSet
    
    func addProgramObject(program: Program) {
        let items = self.mutableSetValueForKey("events")
        items.addObject(program)
    }

}
