//
//  NewsTableViewController.swift
//  iSocialize
//
//  Created by Bengi Sevil on 12/5/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    // Instance variable holding the object reference of the UITableView UI object created in the Storyboard
    @IBOutlet var topNewsTableView: UITableView!
    
    // Obtain the object reference to the App Delegate object
    let applicationDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let tableViewRowHeight: CGFloat = 102.0
    
    let api_key = "b16c6b9b7fb04c7cba1d360a84788a6a"
    
    var eventDataPassed = [String]()
    
    // Alternate table view rows have a background color of MintCream or OldLace for clarity of display
    
    // Define BabyBlue color: #C5E5F5
    let BABY_BLUE = UIColor(red:0.84, green:0.99, blue:1.00, alpha:1.0)
    
    // Define LightPurple color: #E0DFEE
    let LIGHT_PURPLE = UIColor(red:0.88, green:0.87, blue:0.93, alpha:1.0)
    
    //---------- Create and Initialize the Arrays -----------------------
    
    // obtains news as arrays
    var newsDataToPass = [[String]]()
    
    // newsDataToPass is the data object to pass to the downstream view controller
    var selectedNewsDataToPass = [String]()
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        eventDataPassed = applicationDelegate.eventDataPassed
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        /*
         ------------------------------------------------------------------
         1. Obtain JSON data from the URL with API key
         ------------------------------------------------------------------
         */
        
        /*
         The below API query URL returns a JSON file with the following structure:
         
         {
         
         "status":"ok",
         "totalResults":20,
         "articles":
         {
         "source":{
         "id":null,
         "name":"Weather.com"
         },
         "author":"",  ➞   value can be "" or String or null or URL String
         "title":"At Least One Dead as Heavy Snow, Freezing Rain Batters Russia",
         "description":"More than 5,000 were left without power.",
         "url":"https://weather.com/news/news/2018-02-04-russia-moscow-heavy-snow-freezing-rain-deadly",
         "urlToImage":"https://s.w-x.co/ap_18035478863239.jpg",
         "publishedAt":"2018-02-04T15:35:38Z"
         }
         */
        let location = eventDataPassed[8].replacingOccurrences(of: " ", with: "+")
        // Define the API query URL to obtain top news being featured in the US
        let apiUrl = "https://newsapi.org/v2/everything?q="+location+"&from=2018-12-05&sortBy=popularity&apiKey="+api_key
        
        // Create a URL struct data structure from the API query URL string
        let url = URL(string: apiUrl)
        
        /*
         We use the NSData object constructor below to download the JSON data via HTTP in a single thread in this method.
         Downloading large amount of data via HTTP in a single thread would result in poor performance.
         For better performance, NSURLSession should be used.
         */
        
        // Declare jsonData as an optional of type Data
        let jsonData: Data?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             Option mappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try Data(contentsOf: url!, options: NSData.ReadingOptions.mappedIfSafe)
            
        } catch {
            showAlertMessage(messageHeader: "Unexpected Error", messageBody: "Error in Accessing the API URL!")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            
            // The JSON data is successfully obtained from the API
            
            do {
                /*
                 JSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
                 JSONSerialization class method jsonObject returns an NSDictionary object from the given JSON data.
                 */
                let jsonDataDictionary = try JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                let dictionaryOfNewsJsonData = jsonDataDictionary as! Dictionary<String, AnyObject>
                
                /*
                 ---------------------------------------------------------------
                 2. Extract all of the data items of interest from the JSON data
                 ---------------------------------------------------------------
                 */
                
                // Obtain all the news contained in articles
                var articles:NSArray = []
                articles = dictionaryOfNewsJsonData["articles"] as! NSArray
                
                let arr = articles.objectEnumerator().allObjects as? [[String:AnyObject]]
                for curIndex in arr! {
                    
                    //***************************
                    // Obtain News Source Name
                    //***************************
                    
                    var source = ""
                    
                    if curIndex["source"]!["name"] is NSNull {
                        source = "No News Source Available!"
                    } else {
                        if let sourceName = curIndex["source"]!["name"] as! NSString? {
                            source = sourceName as String
                        } else {
                            source = "Unable to obtain!"
                        }
                    }
                    
                    //***************************
                    // Obtain News Title
                    //***************************
                    
                    var title = ""
                    
                    if curIndex["title"] is NSNull {
                        title = "No News Title Available!"
                    } else {
                        if let newsTitle = curIndex["title"] as! NSString? {
                            title = newsTitle as String
                        } else {
                            title = "Unable to obtain!"
                        }
                    }
                    
                    //************************
                    // Obtain URL to Image
                    //************************
                    
                    var urlToImage = ""
                    
                    if curIndex["urlToImage"] is NSNull {
                        urlToImage = "No urlToImage is given."
                    } else {
                        if let imURL = curIndex["urlToImage"] as! NSString? {
                            urlToImage = imURL as String
                        } else {
                            urlToImage = "Unable to obtain!"
                        }
                    }
                    
                    
                    //***************************
                    // Obtain News Website URL
                    //***************************
                    
                    var url = ""
                    
                    if curIndex["url"] is NSNull {
                        url = "No news website URL is given."
                    } else {
                        if let newsURL = curIndex["url"] as! NSString? {
                            url = newsURL as String
                        } else {
                            url = "Unable to obtain!"
                        }
                    }
                    
                    
                    /*
                     ------------------------------------------------------
                     3. Create an array containing all of the news data.
                     ------------------------------------------------------
                     */
                    let newsData = [source, title, url, urlToImage]
                    newsDataToPass.append(newsData)
                }
                
            } catch let error as NSError {
                
                showAlertMessage(messageHeader: "JSON Data", messageBody: "Error in JSON Data Serialization: \(error.localizedDescription)")
                return
            }
            
        }
    }
    
    
    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    
    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // We have only one section in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return newsDataToPass.count
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Obtain the object reference of a reusable table view cell object instantiated under the identifier
        // Company Cell, which was specified in the storyboard
        let cell: NewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "News Cell") as! NewsTableViewCell
        
        // Obtain the stock symbol of the given company
        let newsData = newsDataToPass[rowNumber]
        
        /*
         newsData[0] = News Source
         newsData[1] = News Title
         newsData[2] = News URL
         newsData[3] = News URL for Image
         */
        
        // Set News Thumbnail Image URL
        
        let imgURL = URL(string: newsData[3])
        
        if imgURL == nil {
            cell.photoImage!.image = UIImage(named: "imageUnavailable.png")
        }
        else {
            let newsThumbnail = try? Data(contentsOf: imgURL!)
            
            if let imageData = newsThumbnail {
                cell.photoImage!.image = UIImage(data: imageData)
            } else {
                cell.photoImage!.image = UIImage(named: "imageUnavailable.png")
            }
        }
        
        // Set News Title
        cell.newsTitle.text = newsData[1]
        
        return cell
    }
    
    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    /*
     Informs the table view delegate that the table view is about to display a cell for a particular row.
     Just before the cell is displayed, we change the cell's background color as BABY_BLUE for even-numbered rows
     and LIGHT_PURPLE for odd-numbered rows to improve the table view's readability.
     */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /*
         The remainder operator (RowNumber % 2) computes how many multiples of 2 will fit inside RowNumber
         and returns the value, either 0 or 1, that is left over (known as the remainder).
         Remainder 0 implies even-numbered rows; Remainder 1 implies odd-numbered rows.
         */
        if indexPath.row % 2 == 0 {
            // Set even-numbered row's background color to MintCream, #F5FFFA 245,255,250
            cell.backgroundColor = BABY_BLUE
            
        } else {
            // Set odd-numbered row's background color to OldLace, #FDF5E6 253,245,230
            cell.backgroundColor = LIGHT_PURPLE
        }
    }
    
    //---------------------------
    // Company (Row) Selected
    //---------------------------
    
    // Tapping a row (News) displays data about the selected News
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Obtain the stock symbol of the selected Company
        let selectedNews = newsDataToPass[rowNumber]
        
        selectedNewsDataToPass = selectedNews;
        
        performSegue(withIdentifier: "NewsWebsite", sender: self)
    }
    
    //--------------------------------
    // Detail Disclosure Button Tapped
    //--------------------------------
    
    // This is the method invoked when the user taps the Detail Disclosure button (circle icon with i)
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Obtain the stock symbol of the selected Company
        let selectedNews = newsDataToPass[rowNumber]
        
        selectedNewsDataToPass = selectedNews;
        
        performSegue(withIdentifier: "NewsWebsite", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "NewsWebsite" {
            
            // Obtain the object reference of the destination view controller
            let newsWebViewController: NewsWebViewController = segue.destination as! NewsWebViewController
            
            // Pass the data object to the downstream view controller object
            newsWebViewController.newsDataPassed = selectedNewsDataToPass
        }
    }
    
    /*
     -----------------------------
     MARK: - Display Alert Message
     -----------------------------
     */
    func showAlertMessage(messageHeader header: String, messageBody body: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: header, message: body, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
}
