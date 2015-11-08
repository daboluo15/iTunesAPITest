//
//  DetailedViewController.swift
//  iTunesAPITest
//
//  Created by Bo Gao on 11/8/15.
//  Copyright © 2015 Bo Gao. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {

    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    var albumNameString = ""
    var albumImageUIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumImage.contentMode = .ScaleAspectFit
        albumImage.image = albumImageUIImage
        
        albumName.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        albumName.numberOfLines = 0
        albumName.text = albumNameString
        // Do any additional setup after loading the view.
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
