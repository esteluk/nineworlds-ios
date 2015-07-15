//
//  Program.swift
//  
//
//  Created by Nathan Wong on 14/07/2015.
//
//

import Foundation
import CoreData

class Program: NSManagedObject {
    
    @NSManaged var startDate: NSDate
    @NSManaged var title: String
    @NSManaged var id: NSNumber
    @NSManaged var length: NSNumber
    @NSManaged var programDescription: String
    @NSManaged var people: NSOrderedSet
    @NSManaged var tags: NSOrderedSet
    @NSManaged var location: Location
    
    func loadFromDictionary(dictionary : NSDictionary, manager: DataManager) -> Program {
        
        self.title = dictionary.objectForKey("title") as! String
        
        if let desc = dictionary.objectForKey("desc") as? String {
            self.programDescription = desc
        }
        
        self.id = (dictionary.objectForKey("id") as! NSString).integerValue
        self.length = (dictionary.objectForKey("mins") as! NSString).integerValue

        let date = dictionary.objectForKey("date") as! String
        let time = dictionary.objectForKey("time") as! String
        
        self.startDate = Program.programDateFormatter.dateFromString(date + " " + time)!
        
        // Associate with people
        if let peopleArray = dictionary.objectForKey("people") as? [NSDictionary] {
            for person in peopleArray {
                let p = manager.searchForObjectOtherwiseCreate("Person", id: person.objectForKey("id")) as! Person
                p.name = person.objectForKey("name") as! String
                
                p.addProgramObject(self)
                self.addPersonObject(p)
            }
        }
        
        // Add location
        if let loc = dictionary.objectForKey("loc") as? [String] {
            if loc.count > 0 {
                let l = manager.searchByTitleOtherwiseCreate("Location", title: loc.first!) as! Location
                l.title = loc.first!
                
                l.addProgramObject(self)
                self.location = l
            }
        }
        
        return self
    }
    
    class var programDateFormatter : NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                return dateFormatter
                }()
        }
        return Static.instance
    }
    
    func addPersonObject(person: Person) {
        var items = self.mutableOrderedSetValueForKey("people")
        items.addObject(person)
    }

}

/*
var program = [{
"time": "18:45",
"date": "2015-08-09",
"title": "Critiquing Critique - A criticism workshop",
"tags": ["Creative Writing"],
"id": "377",
"people": [{
"name": "Roz Kaveney",
"id": "78"
}, {
"name": "Tony Keen",
"id": "81"
}, {
"id": "38",
"name": "Val Nolan"
}
],
"mins": "75",
"desc": "For all the contempt in which critics are sometimes held, critical writing is as important to do well as any other sort of writing. Come along and learn from experienced critics about some of the techniques that can be employed.",
"loc": ["Royal A"]
}, {
"mins": "90",
"desc": "\"In The Turn\" is a feature length documentary about a 10-year-old transgender girl who finds acceptance and empowerment in the company of a queer roller derby league.\r\n\r\n\"In The Turn\" is screening as part of our \"Here Be Dragons\" Official Competition.",
"loc": ["Room 41"],
"date": "2015-08-09",
"title": "In The Turn - (2014, dir. Erica Tremblay, 90mins)",
"tags": ["Film Festival"],
"id": "338",
"people": [{
"name": "Tara Brown",
"id": "212"
}
],
"time": "13:30"
}, {
"loc": ["Room 12"],
"desc": "The majority of fanfiction is based on visual media (films, TV shows, etc), but there are also thriving fandoms based on literary works - and the Yuletide rare fandom exchange often includes fanfic based on literature, from the great classics to the Cat in the Hat. What are the challenges of writing in a fandom for which there's no visual reference? What are the opportunities? And, if it's an obscure work, how do you make it a fandom?",
"mins": "75",
"time": "17:00",
"id": "159",
"people": [{
"name": "AL Johnson",
"id": "145"
}, {
"id": "148",
"name": "Alex"
}, {
"id": "123",
"name": "Tanya Brown"
}, {
"name": "irisbleufic",
"id": "18"
}, {
"name": "Jenn Hersey",
"id": "149"
}
],
"tags": ["Fanfic"],
"date": "2015-08-08",
"title": "Literary Fanfic and Book Fandoms - Examining the differences between literary and other fandoms"
}, { */
