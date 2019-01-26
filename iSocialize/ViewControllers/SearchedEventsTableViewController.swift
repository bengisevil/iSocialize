//
//  SearchedEventsTableViewController.swift
//  iSocialize
//
//  Created by Jovan R on 11/15/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit

class SearchedEventsTableViewController: UITableViewController {

    @IBOutlet var searchedEventsTableView: UITableView!
    
    // Alternate table view rows have a background color of MintCream or OldLace for clarity of display
    
    // Define MintCream color: #F5FFFA  245,255,250
    let MINT_CREAM = UIColor(red: 245.0/255.0, green: 255.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    
    // Define OldLace color: #FDF5E6   253,245,230
    let OLD_LACE = UIColor(red: 253.0/255.0, green: 245.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    
    var searchDataPassed = [[String:String]]()
    var eventDataToPass = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        self.title = searchDataPassed[0]["category"]
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

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
        
        return searchDataPassed.count
    }

    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowNumber = (indexPath as NSIndexPath).row
        let cell: SearchedEventTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "searchedEvent", for: indexPath) as! SearchedEventTableViewCell

        let eventTitle = searchDataPassed[rowNumber]["title"]
        cell.titleLabel.text = eventTitle
        
        let cityName = searchDataPassed[rowNumber]["city_name"]
        let regionName = searchDataPassed[rowNumber]["region_name"]
        cell.locationLabel.text = cityName! + ", " + regionName!
        
        let start_time = searchDataPassed[rowNumber]["start_time"]
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy HH:mm"
        
        if let date = dateFormatterGet.date(from: start_time!) {
            cell.startTimeLabel.text = dateFormatterPrint.string(from: date)
        } else {
            cell.startTimeLabel.text = "error"
        }
        
        
        // Set Event Image
        let eventImageUrl = searchDataPassed[rowNumber]["imageURL"]
        if eventImageUrl == "null"{
            cell.searchedEventImageView!.image = UIImage(named: "imageUnavailable.png")
        }
        else{
            if let url = URL(string: eventImageUrl!){
                let eventImageData = try? Data(contentsOf: url)
                
                if let imageData = eventImageData {
                    cell.searchedEventImageView!.image = UIImage(data: imageData)
                } else {
                    cell.searchedEventImageView!.image = UIImage(named: "imageUnavailable.png")
                }
            }
            else{
                cell.searchedEventImageView!.image = UIImage(named: "imageUnavailable.png")
            }
        }
        

        return cell
    }

    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    // Asks the table view delegate to return the height of a given row.
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return tableViewRowHeight
//    }
    
    /*
     Informs the table view delegate that the table view is about to display a cell for a particular row.
     Just before the cell is displayed, we change the cell's background color as MINT_CREAM for even-numbered rows
     and OLD_LACE for odd-numbered rows to improve the table view's readability.
     */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /*
         The remainder operator (RowNumber % 2) computes how many multiples of 2 will fit inside RowNumber
         and returns the value, either 0 or 1, that is left over (known as the remainder).
         Remainder 0 implies even-numbered rows; Remainder 1 implies odd-numbered rows.
         */
        if indexPath.row % 2 == 0 {
            // Set even-numbered row's background color to MintCream, #F5FFFA 245,255,250
            cell.backgroundColor = MINT_CREAM
            
        } else {
            // Set odd-numbered row's background color to OldLace, #FDF5E6 253,245,230
            cell.backgroundColor = OLD_LACE
        }
    }
    
    //---------------------------
    // Event (Row) Selected
    //---------------------------
    
    // Tapping a row (Event) displays data about the selected Event
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let rowNumber = (indexPath as NSIndexPath).row

        // Obtain the stock symbol of the selected Company
        let selectedEvent = searchDataPassed[rowNumber]


        // Typecast the AnyObject to Swift array of String objects
        eventDataToPass = selectedEvent

        performSegue(withIdentifier: "Searched Event Details", sender: self)
    }
    
    //--------------------------------
    // Detail Disclosure Button Tapped
    //--------------------------------
    
    // This is the method invoked when the user taps the Detail Disclosure button (circle icon with i)
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Obtain the stock symbol of the selected Company
        let selectedEvent = searchDataPassed[rowNumber]
        
        // Typecast the AnyObject to Swift array of String objects
        eventDataToPass = selectedEvent
        
        performSegue(withIdentifier: "Event Website", sender: self)
    }

    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Searched Event Details" {
            
            // Obtain the object reference of the destination view controller
            let searchedEventDetailsViewController: SearchedEventDetailsViewController = segue.destination as! SearchedEventDetailsViewController
            
            // Pass the data object to the downstream view controller object
            searchedEventDetailsViewController.eventDataPassed = eventDataToPass
           
            
        } else if segue.identifier == "Event Website" {
            
            // Obtain the object reference of the destination view controller
            let webViewController: WebViewController = segue.destination as! WebViewController
            var dataToPass = [String]()
            
            let url = eventDataToPass["url"]
            let title = eventDataToPass["title"]
            
            dataToPass.append(url!)
            dataToPass.append(title!)
            
            // Pass the data object to the downstream view controller object
            webViewController.dataToBePassed = dataToPass
        }
    }
 

}
