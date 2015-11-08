//
//  ViewController.swift
//  iTunesAPITest
//
//  Created by mahuiye on 11/6/15.
//  Copyright © 2015 Bo Gao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    var data: NSMutableData = NSMutableData()
    
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    
    var scrollView = UIScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height*6/10))
    var pageControl = UIPageControl(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2 - 10, UIScreen.mainScreen().bounds.size.height*6/10 - 40, 20, 20))
    var labelText = UILabel(frame: CGRectMake(10, UIScreen.mainScreen().bounds.size.height*7.5/10, UIScreen.mainScreen().bounds.size.width, 40))
    
    var currentPage = 0;
    
    var jsonResult: NSDictionary?
    var itemArray : NSArray?
    var sortedArray : NSArray?
    var imageArray = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(scrollView);
        
        scrollView.contentSize = CGSize(width: width*4, height: height*6/10);
        scrollView.pagingEnabled = true;
        scrollView.delegate = self;
        setupGestureRecognizer()
        
        pageControl.numberOfPages = 4;
        //当前显示的页数
        pageControl.currentPage = 0
        self.view.addSubview(pageControl)

        let urlPath = "https://itunes.apple.com/search?term=coldplay&entity=album&limit=10"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        print("Search iTunes API at URL \(url)")
        
        print("width is \(width) and height = \(height)")
        
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        print("Connection failed.\(error.localizedDescription)")
    }
    
    func connection(connection: NSURLConnection, didRecieveResponse response: NSURLResponse)  {
        print("Recieved response")
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Recieved a new request, clear out the data object
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the recieved chunk of data to our data object
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Request complete, self.data should now hold the resulting info
        // Convert it to a string
        let dataAsString: NSString = NSString(data: self.data, encoding: NSUTF8StringEncoding)!
        
        print("\(dataAsString)")

        do {
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            itemArray = jsonResult!["results"] as! [[String : AnyObject]]
            
            sortedArray = itemArray!.sort(
                {
                    item1, item2 in
                    let collectionName1 = item1["collectionName"] as! String
                    let collectionName2 = item2["collectionName"] as! String
                    return collectionName1 < collectionName2
                }
            )
            
            print("the count = \(itemArray!.count)")
            
            scrollView.contentSize = CGSize(width: width*CGFloat(itemArray!.count), height: height*6/10);
            pageControl.numberOfPages = itemArray!.count;
            


            var x : CGFloat = 0.0;
            for var i = 0; i < itemArray!.count; i++
            {
                let item = sortedArray![i]
                
                let imageView = UIImageView(frame: CGRectMake(CGFloat(x), 0, self.width, self.height*6/10))
                imageView.contentMode = .ScaleAspectFit
                
                imageView.image = UIImage(named:"FeiLogoblur.png")
                self.scrollView.addSubview(imageView)
                
                var artistName = sortedArray![0]["artistName"] as! NSString
                var albumName = sortedArray![0]["collectionName"] as! NSString

                labelText.text = (artistName as String) + ": " + (albumName as String)
                
                albumName = sortedArray![i]["collectionName"] as! NSString
                
                self.view.addSubview(labelText)
                
                
                //NSString *imagename=[NSString stringWithFormat:@"Image%d.jpg",i];
                
                x += self.width;
                
                
                print("album name = \(item["collectionName"] as! NSString)")
                let artworkURL = item["artworkUrl100"] as! NSString
                print("artworkurl = \(artworkURL)")
                
                let imageQueue: dispatch_queue_t  = dispatch_queue_create("Image Queue", nil);
                dispatch_async(imageQueue){
                    let imageURL: NSURL = NSURL(string: String(artworkURL))!
                    let imageData: NSData  = NSData(contentsOfURL: imageURL)!
                    let image: UIImage = UIImage(data: imageData)!
                    dispatch_async(dispatch_get_main_queue()){
                        imageView.image = image
                        
                        self.imageArray.setObject(image, forKey: albumName as String)
                    }
                }
                
            }
                

        } catch {
            print("Fetch failed: \((error as NSError).localizedDescription)")
        }
    
    }
 
    func setupGestureRecognizer() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapFrom:")
        tapGestureRecognizer.numberOfTapsRequired = 1;
        scrollView.addGestureRecognizer(tapGestureRecognizer);
    }
    
    func handleTapFrom(recognizer: UITapGestureRecognizer){
        //Code to handle the gesture
        print("current page is \(currentPage)")
    
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        currentPage = Int((scrollView.contentOffset.x + (0.5 * width)) / width);
        pageControl.currentPage = currentPage;
        print("clicked on the \(currentPage) page")
        let item = sortedArray![currentPage]
        let artistName = item["artistName"] as! NSString
        let albumName = item["collectionName"] as! NSString
        
        labelText.text = (artistName as String) + ": " + (albumName as String)
        self.view.addSubview(labelText)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoDetails") {
            // pass data to next view
            let detailView = segue.destinationViewController as! DetailedViewController
            
            let item = sortedArray![currentPage]
            let artistName = item["artistName"] as! NSString
            let albumName = item["collectionName"] as! NSString
            
            detailView.albumNameString = (artistName as String) + ": " + (albumName as String)
            detailView.albumImageUIImage = imageArray[albumName] as! UIImage

        }
    }


}

