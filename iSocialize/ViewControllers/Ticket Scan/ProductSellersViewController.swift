//
//  ProductSellersViewController.swift
//  CodeReader
//
//  Created by Tracy Pan on 9/19/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//

import UIKit
import WebKit

class ProductSellersViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    
    // Values of these instance variables are set by the upstream view controller
    var sellerURL: URL?
    var productName = ""
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        // Set the scene title to show the product name
        self.title = productName
        
        /*
         Convert the NSURL object into an NSURLRequest object and store its object
         reference into the local variable request. An NSURLRequest object represents
         a URL load request in a manner independent of protocol and URL scheme.
         */
        let request = URLRequest(url: sellerURL!)
        
        // Ask the webView object to display the web page for the given sellerURL
        webView.load(request)
    }
    
    /*
     ---------------------------------------------
     MARK: - WKNavigationDelegate Protocol Methods
     ---------------------------------------------
     */
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Starting to load the web page. Show the animated activity indicator in the status bar
        // to indicate to the user that the UIWebVIew object is busy loading the web page.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Finished loading the web page. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /*
         Ignore this error if the page is instantly redirected via JavaScript or in another way.
         NSURLErrorCancelled is returned when an asynchronous load is cancelled, which happens
         when the page is instantly redirected via JavaScript or in another way.
         */
        
        if (error as NSError).code == NSURLErrorCancelled  {
            return
        }
        
        // An error occurred during the web page load. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // Create the error message in HTML as a character string and store it into the local constant errorString
        let errorString = "<html><font size=+4 color='red'><p>Unable to Display Webpage: <br />Possible Causes:<br />- No network connection<br />- Wrong URL entered<br />- Server computer is down</p></font></html>" + error.localizedDescription
        
        // Display the error message within the UIWebView object
        // self. is required here since this method has a parameter with the same name.
        self.webView.loadHTMLString(errorString, baseURL: nil)
    }
    
}

