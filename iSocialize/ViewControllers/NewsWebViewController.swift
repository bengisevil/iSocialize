//
//  NewsWebViewController.swift
//  iSocialize
//
//  Created by Bengi Sevil on 12/5/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit
import WebKit

class NewsWebViewController:UIViewController, WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    
    var newsDataPassed = [String]()
    
    /*
     newsDataPassed[0] = News Source
     newsDataPassed[1] = News Title
     newsDataPassed[2] = News URL
     newsDataPassed[3] = News URL for Image
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        //--------------------------------------------------
        // Adjust the title to fit within the navigation bar
        //--------------------------------------------------
        
        let navigationBarWidth = self.navigationController?.navigationBar.frame.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height
        let labelRect = CGRect(x: 0, y: 0, width: navigationBarWidth!, height: navigationBarHeight!)
        let titleLabel = UILabel(frame: labelRect)
        
        // Set window title to news source
        titleLabel.text = newsDataPassed[0]
        
        titleLabel.font = titleLabel.font.withSize(17)
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        self.navigationItem.titleView = titleLabel
        
        // Obtain the URL structure instance from the given companyWebsiteURL
        let newsURL = URL(string: newsDataPassed[2])
        
        // Obtain the URLRequest structure instance from the given companyUrl
        let request = URLRequest(url: newsURL!)
        
        // Ask the web view object to display the web page for the requested URL
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

