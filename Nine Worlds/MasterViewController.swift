//
//  MasterViewController.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 14/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, FilterDelegate, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var filters: [Tag] = [Tag]()
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var titleSegmentedControl : UISegmentedControl {
        if _titleSegmentedControl != nil {
            return _titleSegmentedControl!
        }
        
        let control = UISegmentedControl(items: ["All", "Favourites"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(MasterViewController.titleSegmentedClick(_:)), forControlEvents: UIControlEvents.ValueChanged)
        _titleSegmentedControl = control
        return _titleSegmentedControl!
    }
    
    var _titleSegmentedControl : UISegmentedControl?

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // Do any additional setup after loading the view, typically from a nib.
        if self.filteredTags != nil {
            self.filters = self.filteredTags!
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let navController = controllers[controllers.count-1] as! UINavigationController
            self.detailViewController = navController.topViewController as? DetailViewController
            
        }
        
        self.navigationItem.titleView = self.titleSegmentedControl
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) 
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        do {
            try context.save()
        } catch _ as NSError {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            abort()
        }
    }
    
    // MARK: - IBActions
    func titleSegmentedClick(sender: UISegmentedControl) {
        self.reloadDataWithFilters()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Program
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "filters" {
            let controller = segue.destinationViewController as! FilterController
            controller.parentController = self
            controller.managedObjectContext = self.managedObjectContext
        }
    }
    
    // MARK: - FilterDelegate
    func applyFilters(tags: [Tag]) {
        self.filters = tags
        self.reloadDataWithFilters()
    }
    
    func reloadDataWithFilters() {
        self.fetchedResultsController.fetchRequest.predicate = self.filterPredicate
        NSFetchedResultsController.deleteCacheWithName("Master")
        do {
            try self.fetchedResultsController.performFetch()
        } catch _ {
        }
        
        UIView.transitionWithView(self.tableView,
            duration: 0.3,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: { () -> Void in
                self.tableView.reloadData()
        }, completion: nil)
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch _ as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                abort()
            }
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if let program = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Program {
            
            if program.attending {
                let unfavouriteAction = UITableViewRowAction(style: .Normal, title: "Unfavourite", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                    program.attending = false
                    do {
                        try self.fetchedResultsController.managedObjectContext.save()
                    } catch _ {
                    }
                    tableView.setEditing(false, animated: true)
                })
                
                unfavouriteAction.backgroundColor = Colors.redColor()
                
                return [unfavouriteAction]
            } else {
                let favouriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Favourite") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                    // Do something
                    program.attending = true
                    do {
                        try self.fetchedResultsController.managedObjectContext.save()
                    } catch _ {
                    }
                    tableView.setEditing(false, animated: true)
                }
                
                favouriteAction.backgroundColor = Colors.redColor()
                
                return [favouriteAction]
            }
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: section)) as! Program
        return data.daySectionTitle
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Program
        let programCell = cell as! ProgramCell
        programCell.configure(object)
        programCell.layoutMargins = UIEdgeInsetsZero
    }

    // MARK: - Fetched results controller
    
    var filterPredicate: NSPredicate? {
        
        var favouritePredicate: NSPredicate? = nil
        if self.titleSegmentedControl.selectedSegmentIndex == 1 {
            favouritePredicate = NSPredicate(format: "attending == %@", NSNumber(bool: true))
        }
        
        var fPredicate: NSPredicate? = nil
        if self.filters.count > 0 {
            var predicateArray = [NSPredicate]()
            
            for tag in self.filters {
                predicateArray.append(NSPredicate(format: "ANY tags.title =[cd] %@", tag.title))
            }
            
            fPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: predicateArray)
        }
        
        if favouritePredicate != nil && fPredicate != nil {
            return NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [favouritePredicate!, fPredicate!])
        } else if favouritePredicate != nil {
            return favouritePredicate
        } else if fPredicate != nil {
            return fPredicate
        } else {
            return nil
        }
    }

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Program", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        fetchRequest.predicate = self.filterPredicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "daySection", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	do {
            try _fetchedResultsController!.performFetch()
        } catch _ as NSError {
             // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            
            abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    var filteredTags: [Tag]? {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "filterSelected ==[cd] %@", true)
        let error: NSError? = nil
        let tags = (try! self.managedObjectContext?.executeFetchRequest(fetchRequest)) as! [Tag]
        if error == nil {
            return tags
        } else {
            return nil
        }
    }

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
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

