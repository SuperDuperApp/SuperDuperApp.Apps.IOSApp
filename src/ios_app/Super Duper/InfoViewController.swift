 //
//  InfoViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 2/4/15.
//  Copyright (c) 2015 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let nsBundleObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        let build = nsBundleObject as! String
        self.title = "v" + version + "(" + build + ")"
        

        
        let logButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "close")
        
        self.navigationItem.rightBarButtonItem = logButton
        self.view.backgroundColor = UIColor(rgba: "#4D1549")
        self.navigationController!.navigationBar.backgroundColor = UIColor(rgba: "#4D1549")
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.tintColor = UIColor(rgba: "#B70071")
        self.navigationController!.navigationBar.layer.borderColor = UIColor(rgba: "#4D1549").CGColor
        self.navigationController!.navigationBar.layer.borderWidth = 0
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        

        let wv : UIWebView = UIWebView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.view.addSubview(wv)
        
        wv.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.getsuperduper.com/appinfo")!)) 
        
        // Do any additional setup after loading the view.
    }
    
    func close() {

        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

