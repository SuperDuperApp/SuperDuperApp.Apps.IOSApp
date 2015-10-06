//
//  ShareTableViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 1/6/15.
//  Copyright (c) 2015 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit

class ShareTableViewController: UITableViewController {
    
    

    
    var bName: String? {
        didSet {
        }
    }
    
    var pColor: String? {
        didSet {
        }
    }
    
    var mbName: String? {
        didSet {
        }
    }
    
    var mpColor: String? {
        didSet {
        }
    }
    
    var desc: String? {
        didSet {
        }
    }
    
    var imageUrl: String? {
        didSet {
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func close() {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
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
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareCell", forIndexPath: indexPath) 

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.textLabel!.text = "Pinterest"
        case 1:
            cell.textLabel!.text = "Instagram"
        default:
            cell.textLabel!.text = "Facebook"
            
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.pinterest()
        case 1:
            self.instagram()
        default:
            self.facebook()
            
        }
    }
    
    func pinterest() {
        

        
        let baPinterest = PinterestWrapper.sharedInstance()
        baPinterest.pinRecipe(self.imageUrl, sourceURL:"http://getsuperduper.com", description:self.desc)
        
    }
    
    func instagram() {
        let instagramURL = NSURL(string: "instagram://location?id=1")
        if (UIApplication.sharedApplication().canOpenURL(instagramURL!)) {
            UIApplication.sharedApplication().openURL(instagramURL!)
        } else {
            let alertController = UIAlertController(title: "SuperDuper", message:
                "Install instagram to share!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        /*
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
        }
*/
        
    }
    
    func facebook() {
        
        // http://www.facebook.com/sharer.php?s=100&p[title]=titleheresexily&p[url]=http://www.mysexyurl.com&p[summary]=mysexysummaryhere&p[images][0]=http://www.urltoyoursexyimage.com
        let instagramURL = NSURL(string: "facebook://s=100&p[title]=titleheresexily&p[url]=http://www.mysexyurl.com&p[summary]=mysexysummaryhere&p[images][0]=http://www.urltoyoursexyimage.com")
        if (UIApplication.sharedApplication().canOpenURL(instagramURL!)) {
            UIApplication.sharedApplication().openURL(instagramURL!)
        } else {
            let alertController = UIAlertController(title: "SuperDuper", message:
                "Install facebook to share!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
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
