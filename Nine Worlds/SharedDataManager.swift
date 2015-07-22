//
//  SharedDataManager.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 22/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import CoreData
import UIKit

class SharedDataManager {
    
//    var icloudToken: protocol?
    
    static var ubiquityKey = "uk.co.nathanwong.Nine-Worlds.UbiquityIdentityToken"
    static var haveRequestedICloud = "uk.co.nathanwong.Nine-Worlds.RequestedICloud"
    static var reloadInterfaceNotification = "uk.co.nathanwong.Nine-Worlds.ReloadInterface"
    
    var identityDidChangeNotification: NSObjectProtocol?
    var persistentStoreDidChangeNotification: NSObjectProtocol?
    var persistentStoreWillChangeNotification: NSObjectProtocol?
    var persistentStoreDidImportUbiquitousChangedNotification: NSObjectProtocol?
    
    var persistentStore: NSPersistentStoreCoordinator?
    
    init(store: NSPersistentStoreCoordinator?) {
        let fileManager = NSFileManager.defaultManager()
        let icloudToken = fileManager.ubiquityIdentityToken
        
        self.persistentStore = store
        
        if icloudToken != nil {
            let tokenData = NSKeyedArchiver.archivedDataWithRootObject(icloudToken!)
            NSUserDefaults.standardUserDefaults().setObject(tokenData, forKey: SharedDataManager.ubiquityKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SharedDataManager.ubiquityKey)
        }
        
        let firstLaunchWithIcloudAvailable = !NSUserDefaults.standardUserDefaults().boolForKey(SharedDataManager.haveRequestedICloud)
        if icloudToken != nil && firstLaunchWithIcloudAvailable == true {

        }

    }
    
    func foreground() {
        // Register listener for iCloud availability change
        self.identityDidChangeNotification = NSNotificationCenter.defaultCenter().addObserverForName(NSUbiquityIdentityDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            // Something
        }
        
        self.persistentStoreDidChangeNotification = NSNotificationCenter.defaultCenter().addObserverForName(NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.persistentStore, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification: NSNotification!) -> Void in
            print("Persistent store created")
            
            // Refresh user interface
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: SharedDataManager.reloadInterfaceNotification, object: nil))
        })
        
        self.persistentStoreWillChangeNotification = NSNotificationCenter.defaultCenter().addObserverForName(NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.persistentStore, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification: NSNotification!) -> Void in
            if let context = self.persistentStore?.persistentStores.first?.managedObjectContext {
                context!.performBlockAndWait({ () -> Void in
                    var error: NSError? = nil
                    if context != nil && context!.hasChanges {
                        let success = context!.save(&error)
                        if !success && error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                    
                    context!.reset()
                })
            }
        })
        
        self.persistentStoreDidImportUbiquitousChangedNotification = NSNotificationCenter.defaultCenter().addObserverForName(NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.persistentStore, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification: NSNotification!) -> Void in
            print("Data updated from network")
            if let context = self.persistentStore?.persistentStores.first?.managedObjectContext {
                context!.performBlock({ () -> Void in
                    context!.mergeChangesFromContextDidSaveNotification(notification)
                })
            }
        })
    }
    
    func background() {
        if identityDidChangeNotification != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.identityDidChangeNotification!)
        }
        if persistentStoreDidChangeNotification != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.persistentStoreDidChangeNotification!)
        }
        if persistentStoreWillChangeNotification != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.persistentStoreWillChangeNotification!)
        }
        if persistentStoreDidImportUbiquitousChangedNotification != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.persistentStoreDidImportUbiquitousChangedNotification!)
        }
    }
    
    func buildAlertController() {
        let alertController = UIAlertController(title: "Choose storage option", message: "Would you like to persist app settings and your saved schedule between devices using iCloud?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let localButton = UIAlertAction(title: "Local only", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction!) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: SharedDataManager.haveRequestedICloud)
        }
        
        let iCloudButton = UIAlertAction(title: "Share between devices", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: SharedDataManager.haveRequestedICloud)
        }
    }
    
}