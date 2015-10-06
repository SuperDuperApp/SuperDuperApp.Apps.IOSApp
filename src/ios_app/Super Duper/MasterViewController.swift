//
//  MasterViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 12/21/14.
//  Copyright (c) 2014 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit
import CoreData
import Parse
import MessageUI

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var items : NSArray = NSArray()
    var brandPhotos = [String: UIImage]()
    var bgPhotos = [String: UIImage]()
    var selectedBrand: PFObject? = nil
    
    var loader:UIWebView?

    
    var iMinSessions = 3
    var iTryAgainSessions = 1
    
    //
    //Delete "feedback" pop from app code
    //
    /*
    func rateMe() {
    
        var neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
        var numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
        var storedVersion = NSUserDefaults.standardUserDefaults().stringForKey("version")
        
        let nsBundleObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        let build = nsBundleObject as String
        
        
        
        //if ((!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1))) )
        //if (storedVersion != build)
        if (storedVersion != build) {
            if (numLaunches >= iMinSessions) {
                NSUserDefaults.standardUserDefaults().setObject(build, forKey: "version")
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "numLaunches")
                
                showRateMe()
            } else {
                NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
            }
        }
        
        
    }

    
    
    //
    //Delete "feedback" pop from app code
    //
    
    func showRateMe() {
        var alert = UIAlertController(title: "Enjoying SuperDuper?", message: "Your 5-star rating helps us add colors", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Rate it 5 stars", style: UIAlertActionStyle.Default, handler: { alertAction in
            UIApplication.sharedApplication().openURL(NSURL(string : "itms://itunes.apple.com/us/app/apple-store/id955250799?mt=8")!)
            alert.dismissViewControllerAnimated(true, completion: nil)
            //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
        }))
        alert.addAction(UIAlertAction(title: "No, I have suggestions", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismissViewControllerAnimated(true, completion: nil)
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                mailComposeViewController.setToRecipients(["Duper@getsuperduper.com"])
                mailComposeViewController.setSubject("SuperDuper Suggestions")
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    */
    
    func showLoader(show:Bool) {
        if (show) {
            if (loader == nil) {
                //var loaderWidth = 272
                //var loaderHeight = 272
                let loaderWidth = 289
                let loaderHeight = 327
                let vWidth = self.view.frame.size.width
                let vHeight = self.view.frame.size.height
                let loaderX = (vWidth - CGFloat(loaderWidth)) / 2
                let loaderY = (vHeight - CGFloat(loaderHeight)) / 2
                
                loader = UIWebView(frame: CGRectMake(loaderX, loaderY / 2, CGFloat(loaderWidth), CGFloat(loaderHeight)))
                loader!.backgroundColor = UIColor(rgba: "#F0F1F6")
                loader!.opaque = false
                
                loader!.loadHTMLString("<p style=\"padding-bottom: 0px; font-family: 'Avenir Next Condensed'; color: #4D1549;\">Please Wait....</p><img style='padding-top:0px;' src='SuperDuper_appScreen_loadAnimation.gif'/>", baseURL: NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath))
            }
            
            self.view.addSubview(loader!)
        } else {
            self.loader!.removeFromSuperview()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*
    override func viewDidLayoutSubviews() {
        self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.view.frame.width, 94)
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showLoader(true)
        
        UINavigationBar.appearance().backgroundColor = UIColor(rgba: "#4D1549")
        UINavigationBar.appearance().tintColor = UIColor(rgba: "#B70071")
        UINavigationBar.appearance().layer.borderColor = UIColor(rgba: "#4D1549").CGColor
        UINavigationBar.appearance().layer.borderWidth = 0

        

        self.navigationController!.navigationBar.backgroundColor = UIColor(rgba: "#4D1549")
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.tintColor = UIColor(rgba: "#B70071")
        

        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 84))
        footerView.backgroundColor = UIColor(rgba: "#4D1549")
        
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, 30))
        if let largeFont = UIFont(name: "Avenir Next Condensed", size: 18) {
            label.font = largeFont;
        }
        label.textColor = UIColor(rgba: "#938AA1")
        label.text = "#beautyB4brand"
        label.textAlignment = .Center
        footerView.addSubview(label)
        self.tableView.tableFooterView = footerView
        
        /*
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
*/
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()

        //let infoButton = UIBarButtonItem(barButtonSystemItem: .Custom, target: self, action: "insertNewObject:")
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "SuperDuper_infoIcon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "showInfo")
        self.navigationItem.rightBarButtonItem = infoButton
        //rateMe()

        
        
        
// SuperDuper_appScreen_brands_logo
        
        self.tableView.backgroundColor = UIColor(rgba: "#4D1549")

        
        let logo = UIImage(named: "logo_beta_2X")
        let logoImageView = UIImageView(image: logo)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        logoImageView.frame =  CGRectMake(10, 10, 200, 40);
        let logoView = UIView(frame: CGRectMake(0, 0, 215, 20))
        logoView.addSubview(logoImageView)
        
        self.navigationItem.titleView = logoView
        self.tableView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0)
        
        let query : PFQuery = PFQuery(className: "Brand")
        query.whereKey("visible", equalTo: true)
        query.orderByAscending("name")
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            }
            else {
                NSLog("objects %@", objects as NSArray)
                self.items = NSArray(array: objects)
                self.tableView.reloadData()
                
                for item in self.items {
                    self.getBrandPhotos(item as! PFObject, callback: {
                       self.tableView.reloadData()
                        self.showLoader(false)
                    });
                }
                
                
            }
        })
        
        //NSLog("results %@", self.items)
        
    }
    
    func showInfo() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let infoVC: InfoViewController = storyboard.instantiateViewControllerWithIdentifier("infoView") as!InfoViewController
        
        let nc: UINavigationController = UINavigationController(rootViewController: infoVC)
        
        self.presentViewController(nc, animated: true, completion: nil)

        
        
    }
    
    func createInfoButton() {
        let infoButton = UIBarButtonItem(image: UIImage(named: "SuperDuper_infoIcon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "showInfo")
        self.navigationItem.rightBarButtonItem = infoButton
    }
    
    
    
    func getBrandPhotos(brand:PFObject , callback: (() -> Void)!) {
        let relation : PFRelation = brand.relationForKey("photos")
        let query = relation.query()
        query.whereKey("visible", equalTo: true)
        query.orderByAscending("orderIndex")
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            }
            else {
                NSLog("photos %@", objects as NSArray)
                if (objects.count > 0) {
                    
                    
                    for (index, p) in objects.enumerate() {
                        let photo = objects[index] as! PFObject
                        let pName = photo["name"] as! String
                        let imageFile = photo["image"] as! PFFile
                        if (index == 0) {
                            imageFile.getDataInBackgroundWithBlock({(NSData imageData, NSError error) in
                                if (error != nil) {
                                    
                                } else {
                                    let image = UIImage(data: imageData)
                                    self.brandPhotos[brand.objectId] = image!
                                    self.tableView.reloadData()
                                    
                                }
                            })
                        } else if (pName == "swoosh") {
                            imageFile.getDataInBackgroundWithBlock({(NSData imageData, NSError error) in
                                if (error != nil) {
                                    
                                } else {
                                    let image = UIImage(data: imageData)
                                    self.bgPhotos[brand.objectId] = image!
                                    self.tableView.reloadData()
                                    callback!()
                                }
                            })
                        }
                    }
                    
                    
                    
                    
                    
                } else {
                    callback!()
                }
            }
        })
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
        var error: NSError? = nil
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let object: AnyObject = self.items.objectAtIndex(indexPath.row);
            (segue.destinationViewController as! ProductsTableViewController).detailItem = object
        }
        
        
        //}
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 84
    }
    
    /*
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }*/
    
    /*
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 1;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 84))
        headerView.backgroundColor = UIColor(rgba: "#4D1549")

        let label = UILabel(frame: CGRectMake(50, 20, tableView.frame.width - 100, 64))
        if let largeFont = UIFont(name: "Avenir Next Condensed", size: 18) {
            label.font = largeFont;
        }
        label.textColor = UIColor(rgba: "#938AA1")
        label.text = "Choose a brand of nail polish and discover drugstore dupes:"
        label.textAlignment = .Center
        label.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        headerView.addSubview(label)
        
        
        return headerView
    }
    
    /*
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 84))
        headerView.backgroundColor = UIColor(rgba: "#4D1549")
        
        var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, 30))
        if let largeFont = UIFont(name: "Avenir Next Condensed", size: 18) {
            label.font = largeFont;
        }
        label.textColor = UIColor(rgba: "#938AA1")
        label.text = "#beautyB4brand"
        label.textAlignment = .Center
        headerView.addSubview(label)
        
        return headerView
    }*/
    
    /*
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 44))
        footerView.backgroundColor = UIColor(rgba: "#4D1549")
        
        
        var width = view.frame.size.width
        var height = view.frame.size.height
        var available = width
        var padding = CGFloat(15.0)
        
        if (width > 400) {
            padding = CGFloat(7.0)
        } else if (width > 370) {
            padding = CGFloat(10.0)
        } else {
            padding = CGFloat(10.0)
        }
        
        var buttonWidth = available - padding - 30
        var frame = CGRectMake(20, 5, buttonWidth, 34)
        
        var btn = UIButton(frame: frame)
        btn.layer.borderWidth = 0.5
        btn.layer.backgroundColor = UIColor(rgba: "#4D1549").CGColor
        btn.layer.borderColor = UIColor(rgba: "#B70070").CGColor
        btn.addTarget(self, action: Selector("suggest"), forControlEvents: UIControlEvents.TouchDown)
        if let font = UIFont(name: "Avenir Next Condensed", size: 13) {
            btn.titleLabel!.font = font;
        }
        btn.titleLabel!.textColor = UIColor(rgba: "#ffffff")
        btn.setTitle("  What should we match next?", forState: UIControlState.Normal)
        btn.layer.cornerRadius = 5
        
        var correctImage = UIImage(named: "SuperDuper_icon_send_15x15.png")
        btn.setImage(correctImage, forState: .Normal)
        
        footerView.addSubview(btn)
        
        return footerView
    }*/

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return self.items.count
        /*
        var rows = (self.items.count / 2);
        if ((rows % 2) == 0) {
            rows = Int(rows);
        } else {
            rows = Int(rows) + 1;
            
        }
        return rows;
*/
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        
        
        return cell
    }

    /*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }*/

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        //let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        
        cell.backgroundColor = UIColor(rgba: "#4D1549")
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        //cell.userInteractionEnabled = false
        if (self.items.count > 0) {
            //var newRow = indexPath.row * 2;
            let cellWidth = cell.frame.width
            let cellHeight = cell.frame.height
//            let contentViewWidth = cellWidth - 60
//            let contentViewHeight = cellHeight - 10
//            let purpleColor = UIColor(rgba: "#4D1549")
            
            //if (newRow + 1 < self.items.count) {
                let object = self.items.objectAtIndex(indexPath.row) as! PFObject
                let contentView = self.customCell(object, cell:cell, index:0)
                //button1.tag = newRow
                
                //var contentView = UIView(frame: CGRectMake(15, 5, contentViewWidth, contentViewHeight))
                //contentView.addSubview(button1)
                
            
                /*
                if (newRow + 1 < self.items.count) {
                    let object2 = self.items.objectAtIndex(newRow + 1) as! PFObject
                    var button2 = self.customCell(object2, cell:cell, index:1)
                    button2.tag = newRow + 1
                    contentView.addSubview(button2)
                }*/
                
                //contentView.backgroundColor = UIColor(rgba: "#ffffff")
                //contentView.layer.cornerRadius = 5
                
                
                
                cell.backgroundColor = UIColor(rgba: "#4D1549")
                cell.addSubview(contentView)
            //}
            
            
            
            
            
        }
        
        
    }
    
    func customCell(object: PFObject, cell: UITableViewCell, index:Int) -> UIView {
        //var cellWidth = cell.frame.width / 2 - 20
        let cellWidth = cell.frame.width - 40
        let cellHeight = cell.frame.height - 20
//        var x = CGFloat(0.0)
        //if (index == 1) {
        //    x = cellWidth + CGFloat(10.0)
        //}

        let contentView = UIView(frame: CGRectMake(20, 5, cellWidth, cellHeight))
        contentView.backgroundColor = UIColor(rgba: "#ffffff")
        contentView.layer.cornerRadius = 5
        
        let label:UILabel = UILabel(frame: CGRectMake(65, 0, cellWidth - cellHeight, cellHeight))
        if let largeFont = UIFont(name: "Avenir Next Condensed", size: 16) {
            label.font = largeFont;
        }
        label.textColor = UIColor(rgba: "#ffffff")
        label.text = object["name"] as? String
        label.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0

        
        let imageView:UIImageView = UIImageView(frame: CGRectMake(5, 5, cellHeight - 12, cellHeight - 12))
        if (self.brandPhotos[object.objectId] != nil) {
            imageView.image = self.brandPhotos[object.objectId]
        }
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let bgImageView:UIImageView = UIImageView(frame: CGRectMake(55 , 10, cellWidth - 60, 40))
        if (self.bgPhotos[object.objectId] != nil) {
            bgImageView.image = self.bgPhotos[object.objectId]
            
        }
        
        contentView.addSubview(bgImageView)
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        
        //contentView.addTarget(self, action: "brandAction:", forControlEvents: .TouchUpInside)
        
        return contentView
    }
    /*
    
    func brandAction(sender: UIButton!) {
        // handling code
        //let brand = self.items.objectAtIndex(sender.tag) as! PFObject
        self.selectedBrand = self.items.objectAtIndex(sender.tag) as! PFObject
        
        self.performSegueWithIdentifier("products_segue", sender: self)
        
        
    }*/

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
//        let sortDescriptors = [sortDescriptor]
        
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
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
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

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
    
    
    func suggest() {
        
        /*
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.setToRecipients(["Duper@getsuperduper.com"])
            mailComposeViewController.setSubject("Match Next Suggestion")
            
            
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.google.co.uk"]];
        */
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.facebook.com")!)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        return mailComposerVC
    }
    /*
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Oops", message: "It doesn't look like your device is set up to send email.  Please check your email configuration.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    */
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

