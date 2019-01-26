//
//  SearchEventsViewController.swift
//  iSocialize
//
//  Created by Jovan R on 11/15/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit

class SearchEventsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var categories = [String]()
    var categoryIds = [String]()
    var dateArray = [String]()
    
    // Instantiate an array of dictionaries to store searched events
    var searchedEvents = [[String:String]]()
    
    @IBOutlet var searchLocationTextField: UITextField!
    @IBOutlet var searchKeywordTextField: UITextField!
    @IBOutlet var categoryPickerView: UIPickerView!
    @IBOutlet var dateRangePickerView: UIPickerView!
    @IBOutlet var maxNumberSegmentedControl: UISegmentedControl!
    @IBOutlet var searchButton: UIButton!
    
    // Goes off when search button is pressed
    @IBAction func SearchButtonPressed(_ sender: Any) {
        performSearch()
        performSegue(withIdentifier: "Perform Search", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prepare Picker Data
        getCategories()
        getDates()
        
        // Sort categories in alphabetical order
        categories.sort{ $0 < $1 }
        
        // Show Category Picker View middle row as the selected one
        categoryPickerView.selectRow(Int(categories.count / 2), inComponent: 0, animated: false)
        dateRangePickerView.selectRow(Int(dateArray.count / 2), inComponent: 0, animated:false)
        
        // Style button
        searchButton.backgroundColor = UIColor.clear
        searchButton.layer.cornerRadius = 10
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.blue.cgColor
    }
    
    // Perform the search on the API
    func performSearch(){
        // Clear previous search results
        searchedEvents.removeAll()
        
        /*************** List of Actions Performed below ***************
         1. Form the API search query based on user input
         2. Obtain JSON data from the eventful API for the search query.
         3. Extract all of the data items of interest from the JSON data.
         4. Create a array of dictionaries containing all of the searchedEvent data.
         ********************************************************************/
        
        /*
         ------------------------------------------------
         1. Form the API search query based on user input
         Example query: http://api.eventful.com/json/events/search?app_key=Cn8jSwzSL92VFNc8&keywords=books&category=music&date=Future
        -------------------------------------------------*/
        var apiSearchUrl = "http://api.eventful.com/json/events/search?app_key=Cn8jSwzSL92VFNc8"
        
        // Set Category Parameter
        let category = categoryIds[categoryPickerView.selectedRow(inComponent: 0)]
        apiSearchUrl += "&category=\(category)"
        
        // Set Keyword parameter
        if searchKeywordTextField.text != "" && searchKeywordTextField.text != " "{
            var keyword = searchKeywordTextField.text
            keyword = keyword!.replacingOccurrences(of: " ", with: "+")
            apiSearchUrl += "&keywords=\(keyword!)"
        }
        
        // Set location parameter
        if searchLocationTextField.text != "" && searchLocationTextField.text != " "{
            var location = searchLocationTextField.text
            location = location!.replacingOccurrences(of: " ", with: "+")
            apiSearchUrl += "&location=\(location!)"
        }
        
        // Set page size parameter
        var page_size = 10
        switch maxNumberSegmentedControl.selectedSegmentIndex {
        case 0:
            page_size = 10
        case 1:
            page_size = 20
        case 2:
            page_size = 30
        case 3:
            page_size = 40
        case 4:
            page_size = 50
        default:
            page_size = 10
        }
        apiSearchUrl += "&page_size=\(page_size)"
        
        // Set Date parameter
        var date = dateArray[dateRangePickerView.selectedRow(inComponent: 0)]
        date = date.replacingOccurrences(of: " ", with: "+")
        apiSearchUrl += "&date=\(date)"
        
        /*
         ------------------------------------------------------------------
         2. Obtain JSON data from the Eventful API for the search query         ------------------------------------------------------------------
         */
        // Create a URL struct data structure from the API query URL string
        let url = URL(string: apiSearchUrl)
        
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
            showAlertMessage(messageHeader: "No Results Found!", messageBody: "")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            
            // The JSON data is successfully obtained from the API
            
            /* ----------------------------------------------------------------------------
             3. Extract all of the data items of interest from the JSON data.
             *  API Format provided in google docs *
             ----------------------------------------------------------------------------*/
            /*
             JSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             JSONSerialization class method jsonObject returns an NSDictionary object from the given JSON data.
             */
            
            let jsonDataDictionary = try! JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            // If no items were found using the search criteria
            if jsonDataDictionary["total_items"] as! String == "0"{
                showAlertMessage(messageHeader: "No Items Found", messageBody: "No items were found using the search criteria. Please try another search query.")
                return
            }
            
            let eventsDictionary =  jsonDataDictionary["events"] as! [String:[[String: AnyObject]]]
           
            let resultsArray =  eventsDictionary["event"]
        
            
            // Initialize Variables
            var id = "null"
            var title = "null"
            var latitude = "null"
            var longitude = "null"
            var url = "null"
            var region_name = "null"
            var start_time = "No Start Time Provided."
            var stop_time = "No Stop Time Provided."
            var venue_name = "null"
            var venue_address = "null"
            var city_name = "null"
            var country_name = "null"
            var imageURL = "null"
            var description = "No Description Provided."
            
            for i in 0..<resultsArray!.count{
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                if (resultsArray![i]["id"] as? String) != nil{
                    id = resultsArray![i]["id"] as! String
                }
                if (resultsArray![i]["title"] as? String) != nil{
                    title = resultsArray![i]["title"] as! String
                }
                if (resultsArray![i]["latitude"] as? String) != nil{
                    latitude = resultsArray![i]["latitude"] as! String
                }
                if (resultsArray![i]["longitude"] as? String) != nil{
                    longitude = resultsArray![i]["longitude"] as! String
                }
                if (resultsArray![i]["url"] as? String) != nil{
                    url = resultsArray![i]["url"] as! String
                }
                if (resultsArray![i]["region_name"] as? String) != nil{
                    region_name = resultsArray![i]["region_name"] as! String
                }
                if (resultsArray![i]["start_time"] as? String) != nil{
                    start_time = resultsArray![i]["start_time"] as! String
                }
                if (resultsArray![i]["venue_name"] as? String) != nil{
                     venue_name = resultsArray![i]["venue_name"] as! String
                }
                if (resultsArray![i]["venue_address"] as? String) != nil{
                    venue_address = resultsArray![i]["venue_address"] as! String
                }
                if (resultsArray![i]["city_name"] as? String) != nil{
                    city_name = resultsArray![i]["city_name"] as! String
                }
                if (resultsArray![i]["country_name"] as? String) != nil{
                    country_name = resultsArray![i]["country_name"] as! String
                }
                if (resultsArray![i]["description"] as? String) != nil{
                    description = resultsArray![i]["description"] as! String
                }
                if (resultsArray![i]["stop_time"] as? String) != nil{
                    stop_time = resultsArray![i]["stop_time"] as! String
                }
                if let imageDictionary = resultsArray![i]["image"] as? [String:AnyObject]{
                    if(imageDictionary["url"] as? String) != nil{
                        imageURL = imageDictionary["url"] as! String
                    }
                }
                
                
                // venue_url ?
                
                /* ----------------------------------------------------------------------------
                 4. Create an array of dictionaries containing all of the searchedEvent data.
                 ----------------------------------------------------------------------------*/
                var searchedEvent = [String:String]()
                searchedEvent["id"] = id
                searchedEvent["title"] = title
                searchedEvent["latitude"] = latitude
                searchedEvent["longitude"] = longitude
                searchedEvent["url"] = url
                searchedEvent["start_time"] = start_time
                searchedEvent["stop_time"] = stop_time
                searchedEvent["venue_name"] = venue_name
                searchedEvent["venue_address"] = venue_address
                searchedEvent["country_name"] = country_name
                searchedEvent["region_name"] = region_name
                searchedEvent["city_name"] = city_name
                searchedEvent["imageURL"] = imageURL
                searchedEvent["description"] = description
                searchedEvent["category"] = categories[categoryPickerView.selectedRow(inComponent: 0)].replacingOccurrences(of: "&amp;", with: "&")
                searchedEvents.append(searchedEvent)
            }
        } else {
            showAlertMessage(messageHeader: "JSON Data", messageBody: "Unable to obtain the JSON data file!")
        }
    }
    
    /*
     -----------------------------
     MARK: - Get Categories
     -----------------------------
     */
    func getCategories(){
        let apiCategoriesURL = "http://api.eventful.com/json/categories/list?app_key=Cn8jSwzSL92VFNc8"
        
        // Create a URL struct data structure from the API query URL string
        let url = URL(string: apiCategoriesURL)
        
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
            showAlertMessage(messageHeader: "Category API Unrecognized!", messageBody: "")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            
            // The JSON data is successfully obtained from the API
            
            
            /*
             JSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             JSONSerialization class method jsonObject returns an NSDictionary object from the given JSON data.
             */
            
            /* --------------------------------------
             API Format provided in google docs
             --------------------------------------*/
            
            
            let jsonDataDictionary = try! JSONSerialization.jsonObject(with: jsonDataFromApiUrl, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let categoryDict =  jsonDataDictionary["category"] as! [[String: AnyObject]]
            
            categories.append("All")
            categoryIds.append("All")
            for i in 0..<categoryDict.count{
                // Typecast the returned NSDictionary as Dictionary<String, AnyObject>
                let name = categoryDict[i]["name"] as! String
                categories.append(name)
                let id = categoryDict[i]["id"] as! String
                categoryIds.append(id)
            }
            
        } else {
            showAlertMessage(messageHeader: "JSON Data", messageBody: "Unable to obtain the JSON data file!")
        }
        
    }
    
    // Set up dates for second picker
    func getDates(){
        dateArray.append("Future")
        dateArray.append("Past")
        dateArray.append("Today")
        dateArray.append("Last Week")
        dateArray.append("This Week")
        dateArray.append("Next Week")
        dateArray.append("January")
        dateArray.append("February")
        dateArray.append("March")
        dateArray.append("April")
        dateArray.append("May")
        dateArray.append("June")
        dateArray.append("July")
        dateArray.append("August")
        dateArray.append("September")
        dateArray.append("October")
        dateArray.append("November")
        dateArray.append("December")
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
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     ---------------------------------------
     MARK: - Picker View Data Source Methods
     ---------------------------------------
     */
    
    // Specifies how many components in the Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     // Specifies how many rows in the Picker View component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? categories.count : dateArray.count
    }
    
    /*
     -----------------------------------
     MARK: - Picker View Delegate Method
     -----------------------------------
     */
    
    // Specifies title for a row in the Picker View component
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // Tag number is set in the Storyboard: 1 for dietLabelPickerView and 2 for healthLabelPickerView
        // We use Swift's ternary conditional operator:
        var rowTitle = categories[row]
        rowTitle = rowTitle.replacingOccurrences(of: "&amp;", with: "&")
        
        
        return pickerView.tag == 0 ? rowTitle : dateArray[row]
    }
    
    /*
     ---------------------
     MARK: - Keyboard Done
     ---------------------
     */
    
    // This method is invoked when the user taps the Done key on the keyboard
    @IBAction func keyboardDone(_ sender: UITextField) {
        
        // Once the text field is no longer the first responder, the keyboard is removed
        sender.resignFirstResponder()
    }
    
    /*
     ------------------------------
     MARK: - User Tapped Background
     ------------------------------
     */
    @IBAction func userTappedBackground(sender: AnyObject) {
        /*
         "This method looks at the current view and its subview hierarchy for the text field that is
         currently the first responder. If it finds one, it asks that text field to resign as first responder.
         If the force parameter is set to true, the text field is never even asked; it is forced to resign." [Apple]
         */
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Perform Search" {
            
            // Obtain the object reference of the destination view controller
            let searchedEventsTableViewController: SearchedEventsTableViewController = segue.destination as! SearchedEventsTableViewController
            
            // Pass the data object to the downstream view controller object
            searchedEventsTableViewController.searchDataPassed = searchedEvents
        }
    }
}
