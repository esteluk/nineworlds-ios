//
//  DashboardController.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 24/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import CoreData
import UIKit

class DashboardController : UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UILabel!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var notificationObserver: NSObjectProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        self.notificationObserver = NSNotificationCenter.defaultCenter()
            .addObserverForName(DataManager.IMPORT_COMPLETE, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            
            do {
                try self.nowFetchedResultsController.performFetch()
            } catch _ {
            }
            do {
                try self.nextFetchedResultsController.performFetch()
            } catch _ {
            }
                self.collectionView.reloadData()
                
                self.showEmptyView()
        }
        
        self.showEmptyView()
    }
    
    deinit {
        if self.notificationObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.notificationObserver!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            if let indexPaths = self.collectionView.indexPathsForSelectedItems() {
                let indexPath = indexPaths[0]
                var object: Program
                if indexPath.section == 0 {
                    object = self.nowFetchedResultsController.objectAtIndexPath(indexPath) as! Program
                } else {
                    object = self.nextFetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: indexPath.row, inSection: 0)) as! Program
                }
                
                let dvc = segue.destinationViewController as! DetailViewController
                dvc.detailItem = object
            }
            
        }
    }
    
    func showEmptyView() {
        if self.collectionView.numberOfItemsInSection(0) == 0 &&
            self.collectionView.numberOfItemsInSection(1) == 0 {
                self.collectionView.hidden = true
                self.emptyView.hidden = false
        } else {
            self.collectionView.hidden = false
            self.emptyView.hidden = true
        }
    }
    
    // MARK: UICollectionViewDataSource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let sectionInfo = self.nowFetchedResultsController.sections![section] 
            return sectionInfo.numberOfObjects
        } else if section == 1 {
            let sectionInfo = self.nextFetchedResultsController.sections![0] 
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProgramDetailsCell
        
        var program: Program
        switch indexPath.section {
        case 0:
            program = self.nowFetchedResultsController.objectAtIndexPath(indexPath) as! Program
            break
        
        case 1:
            program = self.nextFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! Program
            break
        
        default:
            program = self.nowFetchedResultsController.objectAtIndexPath(indexPath) as! Program
        }
        
        cell.configure(program)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! ProgramHeader
        
        switch indexPath.section {
        case 0:
            header.titleLabel.text = "On now!"
            
            break
        case 1:
            header.titleLabel.text = "Coming up..."
            break
        default:
            break
        }
        
        return header
    }
    
    // MARK: - UICollectionViewFlowLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = floor(collectionView.frame.size.width / 2) - 15
        let textWidth = width - 16
        
        var object: Program
        if indexPath.section == 0 {
            object = self.nowFetchedResultsController.objectAtIndexPath(indexPath) as! Program
        } else {
            object = self.nextFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! Program
        }
        
        let titleAttribs = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        let subtitleAttribs = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        
        let size1 = NSString(string: object.title).boundingRectWithSize(CGSizeMake(textWidth, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: titleAttribs, context: nil)
        let size2 = NSString(string: object.listDetail).boundingRectWithSize(CGSizeMake(textWidth, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: titleAttribs, context: nil)
        let size3 = NSString(string: object.tagString).boundingRectWithSize(CGSizeMake(textWidth, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: titleAttribs, context: nil)
        
        return CGSizeMake(width, size1.height + size2.height + size3.height + 8 + 24)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if (section == 0 && collectionView.numberOfItemsInSection(section) > 0)
            || (section == 1 && collectionView.numberOfItemsInSection(section) > 0) {
                return CGSizeMake(collectionView.frame.width, 50)
        }
        
        return CGSizeMake(collectionView.frame.width, 0)
        
    }
    
    // NSFetchedResultsControllerDelegate
    
    var nowPredicate: NSPredicate? {
        let now = NSDate()
        let predicate = NSPredicate(format: "startDate <= %@ AND endDate >= %@", now, now)
        return predicate
    }
    
    var nextPredicate: NSPredicate? {
        let now = NSDate()
        let future = NSDate(timeInterval: 90 * 60, sinceDate: now)
        return NSPredicate(format: "startDate > %@", now)
    }
    
    var nowFetchedResultsController: NSFetchedResultsController {
        if _nowFetchedResultsController != nil {
            return _nowFetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Program", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        fetchRequest.predicate = nowPredicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _nowFetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        do {
            try _nowFetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _nowFetchedResultsController!
    }
    var _nowFetchedResultsController: NSFetchedResultsController? = nil
    
    var nextFetchedResultsController: NSFetchedResultsController {
        if _nextFetchedResultsController != nil {
            return _nextFetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Program", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = nextPredicate
        fetchRequest.fetchLimit = 15
        
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFRC.delegate = self
        _nextFetchedResultsController = aFRC
        
        var error: NSError? = nil
        do {
            try _nextFetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            abort()
        }
        
        return _nextFetchedResultsController!
    }
    
    var _nextFetchedResultsController: NSFetchedResultsController? = nil
}
