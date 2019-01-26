//
//  WebViewController.swift
//  iSocialize
//
//  Created by Jovan R on 11/15/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    var dataToBePassed = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = dataToBePassed[1]
        
        // Obtain the URL structure instance from the given articleWebsiteURL
        let articleUrl = URL(string: dataToBePassed[0])
        
        // Obtain the URLRequest structure instance from the given companyUrl
        let request = URLRequest(url: articleUrl!)
        
        // Ask the web view object to display the web page for the requested URL
        webView.load(request)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
