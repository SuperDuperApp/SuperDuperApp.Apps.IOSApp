//
//  AppDelegate.swift
//  Super Duper
//
//  Created by Curtis Wingert on 12/21/14.
//  Copyright (c) 2014 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit
import CoreData
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var noPics = [String: UIImage]()

    //UA-60750666-1
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //UINavigationBar.appearance().backgroundColor = UIColor(rgb: 0x44003E)
        //UINavigationBar.appearance().barStyle = UIBarStyle.
        
        // Configure tracker from GoogleService-Info.plist.
        
        
        // Optional: configure GAI options.
        var gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        gai.trackerWithTrackingId("UA-60750666-1")
        
        var tracker = GAI.sharedInstance().defaultTracker
//        tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "app_launched", label: "App Launched", value: nil).build() as [NSObject : AnyObject])
        
        if let text = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            println(text)
        }

        var pageControl : UIPageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor(rgba: "#B5B9C8")
        pageControl.currentPageIndicatorTintColor = UIColor(rgba: "#B8006F")        
        
        
        Parse.setApplicationId("3sC6jbS7mjqMHE9x2aanasCy6Bd47RnwvA3mQfWo", clientKey: "677CVNL6oDSejztx1HxkW1RNbwPRHWrNj5wPgm5H")
        Parse.enableLocalDatastore()
        // Override point for customization after application launch.
        let navigationController = self.window!.rootViewController as UINavigationController
        let controller = navigationController.topViewController as MasterViewController
        controller.managedObjectContext = self.managedObjectContext
        
        self.getNoPics()
        
        return true
    }

    
    func getNoPics() {
        var query : PFQuery = PFQuery(className: "Settings")
        query.whereKey("visible", equalTo: true)
        query.orderByAscending("name")
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            }
            else {
                NSLog("objects %@", objects as NSArray)
                self.noPics = [String: UIImage]()

                
                for item in objects {
                    var imageFile = item["image"] as PFFile
                    var name = item["name"] as String
                    imageFile.getDataInBackgroundWithBlock({(NSData imageData, NSError error) in
                        if (error != nil) {
                            
                        } else {
                            var image = UIImage(data: imageData)
                            self.noPics[name] = image!
                        }
                    })
                }
                
                
            }
        })
    }
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.getsuperduper.Super_Duper" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Super_Duper", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Super_Duper.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

