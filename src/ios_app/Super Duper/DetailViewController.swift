//
//  DetailViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 12/21/14.
//  Copyright (c) 2014 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit
import Parse
import MessageUI


class DetailViewController: UIViewController, UIPageViewControllerDelegate ,UIPageViewControllerDataSource, MFMailComposeViewControllerDelegate, UIWebViewDelegate {

    
    var colorLabel: UITextView?
    var brandLabel: UITextView?
    var priceLabel: UITextView?
    
    var matchColorLabel: UITextView?
    var matchBrandLabel: UITextView?
    var matchPriceLabel: UITextView?
    
    //var copyWebView: UIWebView?
    
    var pageViewController : UIPageViewController?
    var pageToolbar: UIToolbar?
    var actionsToolbar: UIToolbar?
    var tipsView: UIWebView?

    var items : NSArray = NSArray()
    
    var currentIndex : Int = 0
    var matchIndex : Int = 0
    
    var brand : PFObject?
    var product : PFObject?
    
    var match : PFObject?
    var matchedProduct: PFObject?
    var matchedProductBrand: PFObject?
    var matchPhotos = []
    var matchImages : [UIImage] = []
    var firstMatchImageLoaded = false
    
    var prevButton:UIBarButtonItem?
    var nextButton:UIBarButtonItem?
    var prevTitleButton:UIBarButtonItem?
    var nextTitleButton:UIBarButtonItem?
    
    var suggestButton:UIBarButtonItem?
    //var shareButton:UIBarButtonItem?
    var correctButton:UIBarButtonItem?
    
    var noPicImageView:UIImageView?
    
    var shareView:UIView?
    
    var loader:UIWebView?
    
    var scrollView:UIScrollView?
    var contentView:UIView?
    
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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        
        
        
        if (self.matchPhotos.count > 0) {
            var pColor = self.product!["color"] as String
            var bName = self.brand!["name"] as String
            var mpColor = self.matchedProduct!["color"] as String
            var mbName = self.matchedProductBrand!["name"] as String
            
            var photo = self.matchPhotos[self.currentIndex] as? PFObject
            var imageFile = photo!["image"] as PFFile
            let imageUrl = imageFile.url
            
            let sourceUrl: NSString = "http://getsuperduper.com"
            let description: NSString = "SuperDuper found this : " + bName + " " + pColor + " + " + mbName + " " + mpColor
            
            
            
            (segue.destinationViewController as ShareTableViewController).bName = bName
            (segue.destinationViewController as ShareTableViewController).pColor = pColor
            (segue.destinationViewController as ShareTableViewController).mbName = mbName
            (segue.destinationViewController as ShareTableViewController).mpColor = mpColor
            (segue.destinationViewController as ShareTableViewController).desc = description as String
            (segue.destinationViewController as ShareTableViewController).imageUrl = imageUrl
        } else {
            let alertController = UIAlertController(title: "SuperDuper", message:
                "We're still working on this match! Once we have a photo here, you will be able to share it. In the meantime, go Back and persue other colors!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }

    
    var detailItem: AnyObject? {
        didSet {

            self.showLoader(true)
            
            self.product = self.detailItem as? PFObject
            var relation : PFRelation = self.product!.relationForKey("matches")
            var query = relation.query()
            query.whereKey("visible", equalTo: true)
            query.orderByAscending("orderIndex")
            

            query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
                if (error != nil) {
                    NSLog("error " + error.localizedDescription)
                }
                else {
                    NSLog("objects %@", objects as NSArray)
                    self.items = NSArray(array: objects)
                    if (self.items.count > 0) {
                        self.match = self.items[0] as? PFObject
                        
                        
                    }
                    self.configureView()
                }
            })
            
            var tracker = GAI.sharedInstance().defaultTracker
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "product_selected", label: "ui_action", value: nil).build() as [NSObject : AnyObject])
        }
    }
    
    func configureView() {
        self.clearData()
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            self.getBrand({
                if (self.items.count > 0) {
                    self.loadMatch()
                } else {
                    self.showData()
                }
            })
        }
    }
    
    
    func getBrand(callback: (() -> Void)!) {
        var mb = self.detailItem!["brand"] as? PFObject
        
        mb?.fetchInBackgroundWithBlock({(PFObject object, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            } else {
                self.brand = object
                callback!()
            }
        })
    }
    
    func getMatchProduct(callback: (() -> Void)!) {
        var mp = self.match!["match"] as? PFObject
        
        mp?.fetchInBackgroundWithBlock({(PFObject object, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            } else {
                self.matchedProduct = object as PFObject
                callback!()
            }
        })
    }
    
    func getMatchProductBrand(callback: (() -> Void)!) {
        var mb = self.matchedProduct!["brand"] as? PFObject
        mb?.fetchInBackgroundWithBlock({(PFObject object, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            } else {
                self.matchedProductBrand = object
                callback!()
            }
        })
    }
    
    func getMatchPhotos(callback: (() -> Void)!) {
        var relation : PFRelation = self.match!.relationForKey("photos")
        var query = relation.query()
        query.whereKey("visible", equalTo: true)
        query.orderByAscending("orderIndex")
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            }
            else {
                NSLog("photos %@", objects as NSArray)
                self.matchPhotos = NSArray(array: objects)
                callback!()
            }
        })
    }
    
    
    
    func downloadMatchPhotos(callback: (() ->Void)!) {
        self.matchImages = []
        var downloadCount = 0
        
        if self.matchPhotos.count == 0 {
            //var image = UIImage(named: "no_image.jpg")
            var app = UIApplication.sharedApplication().delegate as AppDelegate
            var image = app.noPics["no_shoot"]
            self.matchImages.append(image!)
            callback()
        } else {
            
            self.downloadPhoto(0, photo: self.matchPhotos[0] as PFObject, callback: callback)
            /*
            for (index, photo) in enumerate(self.matchPhotos) {
                self.matchImages.insert(UIImage(named: "Icon.png")!, atIndex:index)
            }
            
            for (index, photo) in enumerate(self.matchPhotos) {
                
                var mp = photo as PFObject
                var imageFile = mp["image"] as PFFile
                imageFile.getDataInBackgroundWithBlock({(NSData imageData, NSError error) in
                    if (error != nil) {
                        
                    } else {
                        NSLog("loading image")
                        downloadCount++
                        var image = UIImage(data: imageData)
                        self.matchImages[index] = image!
                        if (downloadCount == self.matchPhotos.count) {
                            callback()
                        }
                        
                    }
                })
            }*/
            
        }
    }
    
    
    func downloadPhoto(index: Int, photo:PFObject, callback: (() -> Void)!) {
        var newIndex = index
        var imageFile = photo["image"] as PFFile
        imageFile.getDataInBackgroundWithBlock({(NSData imageData, NSError error) in
            if (error != nil) {
                
            } else {
                var image = UIImage(data: imageData)
                self.matchImages.append(image!)
                newIndex++
                if (newIndex < self.matchPhotos.count) {
                    self.downloadPhoto(newIndex, photo: self.matchPhotos[newIndex] as PFObject, callback: callback)
                } else {
                    callback()
                }
                
            }
        })
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as MatchViewController).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as MatchViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.matchImages.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> MatchViewController?
    {
        if self.matchImages.count == 0 || index >= self.matchImages.count
        {
            return nil
        }
        
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MatchViewController") as MatchViewController
        pageContentViewController.image = self.matchImages[index]
        pageContentViewController.pageIndex = index
        self.currentIndex = index
        
        return pageContentViewController
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        if (self.matchImages.count > 1) {
            return self.matchImages.count
        }
        return 0
        
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.currentIndex
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
    
    func suggest() {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            var pColor = self.product!["color"] as String
            var bName = self.brand!["name"] as String
            mailComposeViewController.setToRecipients(["Duper@getsuperduper.com"])
            mailComposeViewController.setSubject("Dupe Suggestion for " + bName + " " + pColor)

            
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    @IBAction func share() {
        
        if (self.matchPhotos.count > 0) {
            
            
            var pColor = self.product!["color"] as String
            var bName = self.brand!["name"] as String
            var mpColor = self.matchedProduct!["color"] as String
            var mbName = self.matchedProductBrand!["name"] as String
            var activeController = self.pageViewController!.viewControllers.first! as MatchViewController
            var photo = self.matchPhotos[activeController.pageIndex] as? PFObject
            var imageFile = photo!["image"] as PFFile
            let imageUrl = imageFile.url
            
            let sourceUrl: NSString = "http://getsuperduper.com"
            let pinDescription: NSString = "I found this on the SuperDuper app:" + bName + " " + pColor + " = " + mbName + " " + mpColor
            
            var baPinterest = PinterestWrapper.sharedInstance()
            baPinterest.pinRecipe(imageUrl, sourceURL:sourceUrl as String, description:pinDescription as String)
        } else {
            let alertController = UIAlertController(title: "Sorry", message:
                "Once we upload the pic, you can share with your friends.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    func correct() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {

            var pColor = self.product!["color"] as String
            var bName = self.brand!["name"] as String
            var mpColor = self.matchedProduct!["color"] as String
            var mbName = self.matchedProductBrand!["name"] as String
            
            mailComposeViewController.setToRecipients(["Duper@getsuperduper.com"])
            mailComposeViewController.setSubject("NOT DUPES: " + bName + " " + pColor + " + " + mbName + " " + mpColor)

            
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func next() {
        if (self.matchIndex < self.items.count - 1) {
            self.matchIndex++
            self.loadMatch()
            var tracker = GAI.sharedInstance().defaultTracker
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "next_match", label: "ui_action", value: nil).build() as [NSObject : AnyObject])
        }
    }
    
    func previous() {
        if (self.matchIndex > 0) {
            self.matchIndex--
            self.loadMatch()
        }
    }
    
    func updateButtonVisibility() {
        var brandName = ""
        
        if (self.matchedProductBrand != nil) {
            brandName = self.matchedProductBrand!["name"] as String
        }

        
        if (self.items.count == 0 || brandName == "?") {
            self.pageToolbar!.removeFromSuperview()
            
            var actionItems = [
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                suggestButton!,
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            ]
            
            actionsToolbar!.setItems(actionItems, animated: false)
            
        } else {
            var pageItems : [UIBarButtonItem] = []
            if (self.matchIndex > 0) {
                pageItems.append(self.prevButton!)
                pageItems.append(self.prevTitleButton!)
                
            }
            
            pageItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
            
            if (self.matchIndex < self.items.count - 1) {
                pageItems.append(nextTitleButton!)
                pageItems.append(nextButton!)
            }
            pageToolbar!.setItems(pageItems, animated: false)
            /*
            var negSep = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            var w = self.view.frame.width
            
            if (w > 400) {
                negSep.width = -14
            } else if (w > 370) {
                negSep.width = -12
            } else {
                negSep.width = -10
            }*/
            
            var actionItems = [
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                suggestButton!,
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            ]
            
            //correctButton!,
            
            actionsToolbar!.setItems(actionItems, animated: false)
            
        }
        
    }
    
    func loadMatch() {
        showLoader(true)
        clearData()
        self.createPageViewController()
        self.currentIndex = 0
        
        self.match = self.items[self.matchIndex] as? PFObject
        self.pageViewController!.dataSource = nil
        self.firstMatchImageLoaded = false

        self.getMatchProduct({
            self.getMatchProductBrand({
                self.getMatchPhotos({
                    self.showData()
                    self.downloadMatchPhotos({
                        if (!self.firstMatchImageLoaded) {
                            self.firstMatchImageLoaded = true
                            var controller : MatchViewController = self.viewControllerAtIndex(0)!
                            var controllers = [controller]
                            self.pageViewController!.setViewControllers(controllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                        }
                        self.pageViewController!.dataSource = self
                    })
                })
            })
        })
    }
    
    func createPageToolbar() {
        var width = view.frame.size.width
        var height = view.frame.size.height
        pageToolbar = UIToolbar(frame:CGRectMake(0, height - 152, width,  44))
        pageToolbar?.backgroundColor = UIColor(rgba: "#B70071")
        pageToolbar?.barTintColor = UIColor(rgba: "#B70071")

        var prevImage = UIImage(named: "previous_arrow_2X")
        var prevImageView = UIImageView(frame: CGRectMake(0, 0, 15, 15))
        prevImageView.contentMode = UIViewContentMode.ScaleAspectFit
        prevImageView.image = prevImage
        prevButton = UIBarButtonItem(customView: prevImageView)
        
        prevTitleButton = UIBarButtonItem(title: "previous dupe", style: UIBarButtonItemStyle.Plain, target: self, action: "previous")
        prevTitleButton!.tintColor = UIColor(rgba: "#ffffff")
        
        var nextImage = UIImage(named: "next_arrow_2X")
        var nextImageView = UIImageView(frame: CGRectMake(0, 0, 15, 15))
        nextImageView.contentMode = UIViewContentMode.ScaleAspectFit
        nextImageView.image = nextImage
        nextButton = UIBarButtonItem(customView: nextImageView)
        
        nextTitleButton = UIBarButtonItem(title: "next dupe", style: UIBarButtonItemStyle.Plain, target: self, action: "next")
        nextTitleButton!.tintColor = UIColor(rgba: "#ffffff")
        
        if let font = UIFont(name: "Avenir Next Condensed", size: 18) {
            nextTitleButton!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            prevTitleButton!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        

        self.view.addSubview(pageToolbar!)
    }
    
    func createActionsToolbar() {
        var width = view.frame.size.width
        var height = view.frame.size.height
        actionsToolbar = UIToolbar(frame:CGRectMake(0, height - 108, width,  44))
        actionsToolbar!.backgroundColor = UIColor(rgba: "#4D1549")
        actionsToolbar!.barTintColor = UIColor(rgba: "#4D1549")


        

        var suggestImage = UIImage(named: "SuperDuper_icon_send_15x15.png")
        var suggestBtn:UIButton = createActionButton(" Suggest another dupe", action: "suggest")
        suggestBtn.setImage(suggestImage, forState: .Normal)
        suggestButton = UIBarButtonItem(customView: suggestBtn)
        
        //var correctImage = UIImage(named: "SuperDuper_icon_send_15x15.png")
        //var correctBtn:UIButton = createActionButton(" Think we got it wrong?", action: "correct")
        //correctBtn.setImage(correctImage, forState: .Normal)
        //correctButton = UIBarButtonItem(customView: correctBtn)
        
        self.view.addSubview(actionsToolbar!)
    }

    func createActionButton(title:String, action:String) -> UIButton {
        var width = view.frame.size.width
        var height = view.frame.size.height
        var available = width / 2
        var padding = CGFloat(15.0)
        
        if (width > 400) {
            padding = CGFloat(7.0)
        } else if (width > 370) {
            padding = CGFloat(10.0)
        } else {
            padding = CGFloat(10.0)
        }

        var buttonWidth = available - padding
        var frame = CGRectMake(0, 5, buttonWidth, 34)
        
        var btn = UIButton(frame: frame)
        btn.layer.borderWidth = 0.5
        btn.layer.backgroundColor = UIColor.clearColor().CGColor
        btn.layer.borderColor = UIColor(rgba: "#B70070").CGColor
        btn.layer.cornerRadius = 5

        btn.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchDown)
        if let font = UIFont(name: "Avenir Next Condensed", size: 13) {
            btn.titleLabel!.font = font;
        }
        btn.titleLabel!.textColor = UIColor(rgba: "#ffffff")
        btn.setTitle(title, forState: UIControlState.Normal)
        return btn
    }
    
    func createTipsView() {
        var width = view.frame.size.width
        var height = view.frame.size.height
        
        var plEnd = (priceLabel!.frame.origin.y + priceLabel!.frame.height)
        var pgTbStart = self.pageToolbar!.frame.origin.y
        var tipsHeight = pgTbStart - plEnd
        var tipsWidth = width - 40
        var toolBarHeights = CGFloat(88)
        var startingY = plEnd
        
        tipsView = UIWebView(frame: CGRectMake(20, startingY, tipsWidth, 5))
        tipsView!.backgroundColor = UIColor(rgba: "#F0F1F6")
        tipsView!.delegate = self
    }
    
    func createPageViewController() {

        if (pageViewController != nil) {
            pageViewController!.removeFromParentViewController()
            pageViewController!.view.removeFromSuperview()
        }

        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.view.frame = CGRectMake(20, 4, 280,  280);
        addChildViewController(pageViewController!)
        contentView!.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func createDataLabels() {
        var width = view.frame.size.width
        var height = view.frame.size.height
        var singleLineHeight = CGFloat(23.0)
        var tripleLineHeight = CGFloat(53.0)
        var priceHeight = CGFloat(25.0)
        
        var vPadding = CGFloat(-6.0)
        var leftColX = CGFloat(20.0)
        var purpleColor = UIColor(rgba: "#4D1549")
        var greyColor = UIColor(rgba: "#B5B9C8")
        
        var startingY = pageViewController!.view.frame.origin.y + pageViewController!.view.frame.size.height
        
        var divider = UIView(frame: CGRectMake((width - 2) / 2, startingY, 0.5, singleLineHeight + tripleLineHeight + priceHeight + (vPadding * 3)))
        divider.backgroundColor = greyColor
        
        var rightColX = divider.frame.origin.x + 20
        var labelWidth = divider.frame.origin.x - 25
        
        
        brandLabel = UITextView(frame: CGRectMake(leftColX, startingY, labelWidth, singleLineHeight))
        colorLabel = UITextView(frame: CGRectMake(leftColX, brandLabel!.frame.origin.y + brandLabel!.frame.size.height + vPadding, labelWidth, tripleLineHeight))
        priceLabel = UITextView(frame: CGRectMake(leftColX, colorLabel!.frame.origin.y + colorLabel!.frame.size.height + vPadding, labelWidth, priceHeight))
        
        matchBrandLabel = UITextView(frame: CGRectMake(rightColX, startingY, labelWidth, singleLineHeight))
        matchColorLabel = UITextView(frame: CGRectMake(rightColX, matchBrandLabel!.frame.origin.y + matchBrandLabel!.frame.size.height + vPadding, labelWidth, tripleLineHeight))
        matchPriceLabel = UITextView(frame: CGRectMake(rightColX, matchColorLabel!.frame.origin.y + matchColorLabel!.frame.size.height + vPadding, labelWidth, priceHeight))
        
        
        colorLabel!.text = ""
        brandLabel!.text = ""
        priceLabel!.text = ""
        
        matchColorLabel!.text = ""
        matchBrandLabel!.text = ""
        matchPriceLabel!.text = ""
        
        colorLabel!.editable = false
        brandLabel!.editable = false
        priceLabel!.editable = false
        matchColorLabel!.editable = false
        matchBrandLabel!.editable = false
        matchPriceLabel!.editable = false
        

        colorLabel!.selectable = false
        brandLabel!.selectable = false
        priceLabel!.selectable = false
        matchColorLabel!.selectable = false
        matchBrandLabel!.selectable = false
        matchPriceLabel!.selectable = false
        
        colorLabel!.scrollEnabled = false
        brandLabel!.scrollEnabled = false
        priceLabel!.scrollEnabled = false
        matchColorLabel!.scrollEnabled = false
        matchBrandLabel!.scrollEnabled = false
        matchPriceLabel!.scrollEnabled = false
        

        
        var ciTop = CGFloat(-11.0)
        var ciLeft = CGFloat(-4.0)
        var ciBottom = CGFloat(-11.0)
        var ciRight = CGFloat(0.0)
        
        

        //colorLabel!.contentInset = UIEdgeInsetsMake(-4,-8,0,0)

        colorLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        brandLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        priceLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        matchColorLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        matchBrandLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        matchPriceLabel!.contentInset = UIEdgeInsetsMake(ciTop, ciLeft, ciBottom, ciRight)
        
        if let font = UIFont(name: "Avenir Next Condensed", size: 12) {
            brandLabel!.font = font;
            matchBrandLabel!.font = font;
        }
        
        if let font = UIFont(name: "Avenir Next Condensed", size: 14) {
            
            priceLabel!.font = font;
            matchPriceLabel!.font = font;
        }
        

        if let largeFont = UIFont(name: "Avenir Next Condensed", size: 16) {
            colorLabel!.font = largeFont;
            matchColorLabel!.font = largeFont;
        }
        
        
        var brandLabelHeight = brandLabel!.frame.size.height
        
        colorLabel!.textColor = purpleColor
        brandLabel!.textColor = purpleColor
        matchColorLabel!.textColor = purpleColor
        matchBrandLabel!.textColor = purpleColor
        
        priceLabel!.textColor = greyColor
        matchPriceLabel!.textColor = greyColor
        
        //colorLabel!.numberOfLines = 4
        //matchColorLabel!.numberOfLines = 4
        
        self.contentView!.addSubview(brandLabel!)
        self.contentView!.addSubview(colorLabel!)
        self.contentView!.addSubview(priceLabel!)
        self.contentView!.addSubview(matchBrandLabel!)
        self.contentView!.addSubview(matchColorLabel!)
        self.contentView!.addSubview(matchPriceLabel!)
        self.contentView!.addSubview(divider)
        
    }
    
    func clearData() {
        
        colorLabel!.text = ""
        brandLabel!.text = ""
        priceLabel!.text = ""
        
        matchColorLabel!.text = ""
        matchBrandLabel!.text = ""
        matchPriceLabel!.text = ""
        
        tipsView!.removeFromSuperview()
        
        
        tipsView!.loadHTMLString("", baseURL: nil)
    }
    
    
    func showData() {
        var price = Double(0)
        if (self.product!["price"] is Double) {
            price = self.product!["price"] as Double
        }
        
        
        var brandStr = self.brand!["name"] as String
        brandStr += "\n"
        
        var copyStr = ""
        
        var html = "<body style=\"background-color:#F0F1F6;\"><p id=\"copyText\"><img width='15' height='15' style='padding-top: 2px; position: absolute;' src='SuperDuper_results_tipsIcon_2X.png'/><span style=\"font-family: 'Avenir Next Condensed'; color: #4D1549; background-color:#F0F1F6; font-size:16px; \">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SuperDuper Tip:</span><br/><span style=\"font-family: 'Avenir Next Condensed'; color: #4D1549; background-color:#F0F1F6; font-size:12px; \">"
        if (self.items.count > 0) {
            var mPrice = Double(0)
            if (self.matchedProduct!["price"] is Double) {
                mPrice = self.matchedProduct!["price"] as Double
            }
            
            var mBrandStr = self.matchedProductBrand!["name"] as String
            mBrandStr += "\n"
            var cLbl = self.matchedProduct!["color"] as? String
            matchColorLabel!.text = (cLbl != "?") ? cLbl : ""
            matchBrandLabel!.text = mBrandStr
            matchPriceLabel!.text = (mPrice > 0) ? NSString(format:"$%.2f", mPrice) as String : ""
            
            copyStr = self.match!["displayCopy"] as String
            html += copyStr
            html += "</span></p></body>"
        } else {
            matchBrandLabel!.text = "?"
            html += "We're still working on it! In the meantime, go Back and persue other colors!</p>"
            
            
        }
        
        if (self.items.count < 2) {
            pageToolbar?.removeFromSuperview()
        }
        
        if (copyStr != "") {
            tipsView!.loadHTMLString(html, baseURL: NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath))
            self.contentView!.addSubview(tipsView!)
        }
        
        var coLbl = self.product!["color"] as? String
        colorLabel!.text = (coLbl != "?") ? coLbl : ""
        brandLabel!.text = brandStr
        priceLabel!.text = (price > 0) ? NSString(format:"$%.2f", price) as String : ""
        
        
        if (self.noPicImageView == nil) {
            self.noPicImageView = UIImageView(frame: CGRectMake(self.pageViewController!.view.frame.origin.x, self.pageViewController!.view.frame.origin.y, self.pageViewController!.view.frame.size.width, self.pageViewController!.view.frame.size.height - 20))
            
            
            //var image = UIImage(named: "no_dupes.jpg")
            var app = UIApplication.sharedApplication().delegate as AppDelegate
            var image = app.noPics["no_dupes"]
            
            if (items.count > 0) {
                //image = UIImage(named: "SuperDuper_appScreens_results_noShoot2.jpg")
                var app = UIApplication.sharedApplication().delegate as AppDelegate
                var image = app.noPics["no_shoot"]
            }
            
            self.noPicImageView!.image = image
        }
        
        if (self.matchPhotos.count == 0 && self.match == nil) {
            self.contentView!.addSubview(self.noPicImageView!)
        } else if (self.items.count == 0) {
            self.contentView!.addSubview(self.noPicImageView!)
        } else {
            self.noPicImageView!.removeFromSuperview()
        }
        
        self.updateButtonVisibility()
        showLoader(false)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var h = tipsView!.stringByEvaluatingJavaScriptFromString("document.getElementById(\"copyText\").offsetHeight;")
        if (h != "") {
            var newHeight = h!.toInt()! + 20
            
            tipsView!.frame = CGRectMake(tipsView!.frame.origin.x, tipsView!.frame.origin.y, tipsView!.frame.size.width, CGFloat(newHeight))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().backgroundColor = UIColor(rgba: "#4D1549")
        UINavigationBar.appearance().tintColor = UIColor(rgba: "#4D1549")
        self.navigationItem.title = "The Dupes"
        self.view.backgroundColor = UIColor(rgba: "#4D1549")
        contentView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 600))
        contentView!.backgroundColor = UIColor(rgba: "#ffffff")
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 44))
        scrollView!.contentSize = CGSizeMake(contentView!.frame.size.width, contentView!.frame.size.height)
        scrollView!.addSubview(contentView!)
        //scrollView!.backgroundColor = UIColor(rgba: "#aabbcc")
        self.view.addSubview(scrollView!)
        var bounds = contentView!.bounds;
        bounds.origin = CGPointMake(0, 0);
        contentView!.bounds = bounds;
        
        createActionsToolbar()
        createPageToolbar()
        
        createPageViewController()
        createDataLabels()
        createTipsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

