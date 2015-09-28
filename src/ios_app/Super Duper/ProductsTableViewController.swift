//
//  ProductsTableViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 12/21/14.
//  Copyright (c) 2014 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class ProductsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var items : NSArray = NSArray()
    
    
    var loader:UIWebView?
    
    func showLoader(show:Bool) {
        if (show) {
            if (loader == nil) {
                //var loaderWidth = 272
                //var loaderHeight = 272
                var loaderWidth = 289
                var loaderHeight = 327
                var vWidth = self.view.frame.size.width
                var vHeight = self.view.frame.size.height
                var loaderX = (vWidth - CGFloat(loaderWidth)) / 2
                var loaderY = (vHeight - CGFloat(loaderHeight)) / 2
                
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().backgroundColor = UIColor(rgba: "#4D1549")
        UINavigationBar.appearance().tintColor = UIColor(rgba: "#4D1549")
        self.tableView.backgroundColor = UIColor(rgba: "#4D1549")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

        
    }
    
    var detailItem: AnyObject? {
        didSet {
            self.showLoader(true)
            var obj = self.detailItem as! PFObject
            self.navigationItem.title = obj["name"] as? String
            
            // Update the view.
            var query : PFQuery = PFQuery(className: "Product")
            query.whereKey("brand", equalTo: self.detailItem)
            query.whereKey("visible", equalTo: true)
            query.orderByAscending("color")
            query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
                if (error != nil) {
                    NSLog("error " + error.localizedDescription)
                }
                else {
                    //NSLog("objects %@", objects as NSArray)
                    self.items = NSArray(array: objects)
                    self.tableView.reloadData()
                    self.showLoader(false)
                }
            })
            
            var tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "brand_selected", label: obj["name"] as? String, value: nil).build() as [NSObject : AnyObject])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.items.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the cell...
        let object = self.items.objectAtIndex(indexPath.row) as! PFObject
        
        var lbl : UILabel = cell.viewWithTag(999) as! UILabel
        lbl.text = object["color"] as? String
        
        var vw = cell.viewWithTag(998)
        
        var hex = "#eaeaea"
        
        if (object["hex"] as! NSString != "") {
            hex = object["hex"] as! NSString as String
        }
        
        var backgroundColor = UIColor(rgba: hex)
        vw?.backgroundColor = backgroundColor
        vw?.layer.cornerRadius = vw!.bounds.size.width / 2
        vw?.layer.masksToBounds = true
        
        //cell.textLabel!.text = object["color"] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
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
        btn.setTitle("  Tell us what color we're missing", forState: UIControlState.Normal)
        btn.layer.cornerRadius = 5
        
        var correctImage = UIImage(named: "SuperDuper_icon_send_15x15.png")
        btn.setImage(correctImage, forState: .Normal)

        footerView.addSubview(btn)
        
        
        
        return footerView
    }
    
    func suggest() {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            var bName = self.detailItem!["name"] as! String
            mailComposeViewController.setToRecipients(["Duper@getsuperduper.com"])
            mailComposeViewController.setSubject("Color Suggestion for " + bName )
            
            
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Oops", message: "It doesn't look like your device is set up to send email.  Please check your email configuration.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            var object: AnyObject = self.items.objectAtIndex(indexPath.row);
            (segue.destinationViewController as! DetailViewController).detailItem = object
        }
        

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
