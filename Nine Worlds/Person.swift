//
//  Person.swift
//  
//
//  Created by Nathan Wong on 14/07/2015.
//
//

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var id: NSNumber
    @NSManaged var bio: String
    @NSManaged var imgLink: String
    @NSManaged var bioLink: String
    @NSManaged var programItems: NSSet
    @NSManaged var tags: NSSet
    
    func loadFromDictionary(dictionary: NSDictionary) -> Person {
        self.id = (dictionary.objectForKey("id") as! NSString).integerValue
        
        let names = dictionary.objectForKey("name") as! [String]
        self.name = (" ").join(names)
        
        if let bio = dictionary.objectForKey("bio") as? String {
            self.bio = bio
        }
        
        if let links = dictionary.objectForKey("links") as? NSDictionary {
            if let bioLink = links.objectForKey("bio") as? String {
                self.bioLink = bioLink
            }
            
            if let imgLink = links.objectForKey("img") as? String {
                self.imgLink = imgLink
            }
        }
        
        return self
    }
    
    func addProgramObject(program: Program) {
        var items = self.mutableSetValueForKey("programItems")
        items.addObject(program)
    }

}

/*
var people = [{
"id": "96",
"tags": [],
"bio": "Dragons, Spaceships, Math stuff",
"links": {
"bio": "https:\/\/nineworlds.co.uk\/2015\/guest\/stephen-deas",
"img": "https:\/\/nineworlds.co.uk\/sites\/nineworlds.co.uk\/files\/styles\/guestimage\/public\/guestphotos\/Stephen%20Deas%20headshot.jpg"
},
"prog": ["190"],
"name": ["Stephen", "Deas", ""]
}, {
"id": "14",
"tags": [],
"name": ["Christine", "Ni", ""],
"bio": "Writer, Translator and Speaker",
"links": {
"bio": "https:\/\/nineworlds.co.uk\/2015\/guest\/christine-ni",
"img": "https:\/\/nineworlds.co.uk\/sites\/nineworlds.co.uk\/files\/styles\/guestimage\/public\/guestphotos\/christine-ni.jpg"
},
"prog": ["239"]
}, {
"tags": [],
"id": "146",
"prog": ["158"],
"bio": null,
"links": {
"img": null,
"bio": null
},
"name": ["Juliet", "Mushens", ""]
}, {*/