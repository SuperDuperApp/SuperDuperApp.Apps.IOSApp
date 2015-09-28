//
//  MatchViewController.swift
//  Super Duper
//
//  Created by Curtis Wingert on 12/21/14.
//  Copyright (c) 2014 LK (ad)Ventures, LLC. All rights reserved.
//

import UIKit
import Parse

class MatchViewController: UIViewController{



    /*
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var matchColorLabel: UILabel!
    @IBOutlet weak var matchBrandLabel: UILabel!
    @IBOutlet weak var matchPriceLabel: UILabel!
    */
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex : Int = 0
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.layer.borderColor = UIColor(rgba: "#F0F1F6").CGColor
        self.imageView.layer.borderWidth = 1
        //self.imageView.contentMode = UIViewContentMode.ScaleToFill
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
