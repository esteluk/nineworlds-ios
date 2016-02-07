//
//  FilterController.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 21/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import CoreData
import UIKit

class FilterController : UIViewController, NSFetchedResultsControllerDelegate, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var parentController: FilterDelegate? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    // Mark - IBAction
    @IBAction func donePressed(sender: UIBarButtonItem) {
        do {
            try self.managedObjectContext?.save()
        } catch _ {
        }
        
        self.parentController?.applyFilters(filteredTags)
    }
    
    @IBAction func clearPressed(sender: UIBarButtonItem) {
        var indexpaths = [NSIndexPath]()
        for tag in self.filteredTags {
            indexpaths.append(self.fetchedResultsController.indexPathForObject(tag)!)
            tag.filterSelected = false
        }
        do {
            try self.fetchedResultsController.managedObjectContext.save()
        } catch _ {
        }
        self.tableView.reloadRowsAtIndexPaths(indexpaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - Fetched results controller
    
    var filteredTags: [Tag] {
        let tags = self.fetchedResultsController.fetchedObjects as! [Tag]
        return tags.filter( {(tag: Tag) -> Bool in
            return tag.filterSelected == true
        })
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                    self.configureCell(cell, atIndexPath: indexPath!)
                }
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // MARK - UINavigationBarDelegate
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    // MARK: - UITableViewDatasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let tag = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        cell.textLabel?.text = tag.title
        
        if tag.filterSelected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        tag.filterSelected = !tag.filterSelected
        
        configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
    }
}

protocol FilterDelegate {
    func applyFilters(tags: [Tag])
}
