//
//  Tag.swift
//  
//
//  Created by Nathan Wong on 14/07/2015.
//
//

import Foundation
import CoreData

class Tag: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var filterSelected: Bool
    @NSManaged var title: String
    @NSManaged var programs: NSOrderedSet
    @NSManaged var people: NSOrderedSet
    
    func addProgramObject(program: Program) -> Void {
        var items = self.mutableOrderedSetValueForKey("programs")
        items.addObject(program)
    }

}
