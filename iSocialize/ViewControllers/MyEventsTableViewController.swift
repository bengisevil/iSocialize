import UIKit
//
//  MyEventsTableViewController.swift
//  EventsILike
//
//  Created by Bengi Sevil on 11/28/2018.
//  Copyright © 2018 Bengi Sevil. All rights reserved.
//

import UIKit

class MyEventsTableViewController: UITableViewController {
    
    @IBOutlet var myEventsTableView: UITableView!
    
    // Obtain the object reference of the App Delegate object
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Alternate table view rows have a background color of MintCream or OldLace for clarity of display
    
    // Define BabyBlue color: #C5E5F5
    let BABY_BLUE = UIColor(red:0.84, green:0.99, blue:1.00, alpha:1.0)
    
    // Define LightPurple color: #E0DFEE
    let LIGHT_PURPLE = UIColor(red:0.88, green:0.87, blue:0.93, alpha:1.0)
    
    //---------- Create and Initialize the Arrays -----------------------
    
    var eventIds = [String]()
    
    // companyDataToPass is the data object to pass to the downstream view controller
    var eventDataToPass = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Set up the Edit button on the left of the navigation bar to enable editing of the table view rows
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Set up the Add button on the right of the navigation bar to call the addEvent method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MyEventsTableViewController.addEvent(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Obtain the updated dictionary as a regular swift dictionary with the same format
        let tempDict = appDelegate.dict_MyEvents as? [String:[String]]
        
        // Sort the dictionary by event date, which is the
        let sorted = tempDict!.sorted(by: {($0.value[3]) < ($1.value[3])}).map{$0.key}
        
        eventIds = sorted
    }
    
    /*
     -------------------------
     MARK: - Add Event Method
     -------------------------
     */
    
    // The addEvent method is invoked when the user taps the Add (+) button
    @objc func addEvent(_ sender: AnyObject) {
        
        // Perform the segue named Add Event
        performSegue(withIdentifier: "Add Event", sender: self)
    }
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToEventsILikeTableViewController (segue : UIStoryboardSegue) {
        
        if segue.identifier == "AddEvent-Save" {
            
            // Obtain the object reference of the source view controller
            let searchedEventDetailsViewController: SearchedEventDetailsViewController = segue.source as! SearchedEventDetailsViewController
            
            // Get the Event Data as a dictionary
            let eventDataObtained:[String:String] = searchedEventDetailsViewController.eventDataPassed
            
            /*
             eventDataObtained[n] = [["id":"E0-001-114645349-0@2019072319"],
             ["title":"The Book Of Mormon"],
             ["latitude":"32.717426"],
             ["longitude":"-117.1624216"],
             ["start_time":"2019-07-23 19:00:00"],
             ["venue_name":"San Diego Civic Theatre"],
             ["venue_address":"1100 Third Avenue"],
             ["region_name":"California"],
             ["city_name":"San Diego"],
             ["imageURL":"http://d1marr3m5x4iac.cloudfront.net/images/small/I0-001/004/097/144-8.jpeg_/the-book-of-mormon-44.jpeg"],
             ["description":"It might be hard for some people to believe that the hottest musical on something as dignified as Broadway, is a parody called The Book of Mormon. While some had their reservations (and many still do) about the quality of a play that satirizes a single religion, audiences and critics are applauding the production values, songs, acting, and well-developed plot. Even the Church of Jesus Christ of Latter-day Saints isn't condemning the production, only emphasizing the line between fiction and reality. Because The Book of Mormon isn't ridiculing Mormonism, it's parodying all organized religion; and doing so in true Broadway fashion."],
             ["category":"Concerts&amp;Tour Dates"]]
             */
            
            let eventData = [eventDataObtained["title"], eventDataObtained["latitude"],eventDataObtained["longitude"],eventDataObtained["start_time"],eventDataObtained["stop_time"],eventDataObtained["venue_name"],eventDataObtained["venue_address"],eventDataObtained["region_name"],eventDataObtained["city_name"],eventDataObtained["imageURL"],eventDataObtained["description"],eventDataObtained["category"]]
            
            let eventIdAsKey = eventDataObtained["id"]
            
            
            //Add the created array under the event id Key to the dictionary dict_MyEvents held by the app delegate object.
            appDelegate.dict_MyEvents.setObject(eventData, forKey: eventIdAsKey! as NSCopying)
            
            // Obtain the updated dictionary as a regular swift dictionary with the same format
            print(appDelegate.dict_MyEvents)
            let tempDict = appDelegate.dict_MyEvents as! [String:[String]]
            
            
            // Sort the dictionary by event date, which is the
            let sorted = tempDict.sorted(by: {($0.value[3]) < ($1.value[3])}).map{$0.key}
            
            eventIds = sorted
            
            /*
             --------------------------
             Update myEventsTableView
             --------------------------
             */
            myEventsTableView.reloadData()
            
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
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
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
        
        return eventIds.count
    }
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Obtain the object reference of a reusable table view cell object instantiated under the identifier
        // EventCell, which was specified in the storyboard
        let cell: MyEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! MyEventsTableViewCell
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        
        // Obtain the name of the given genre
        let givenEventId = eventIds[rowNumber]
        
        // Obtain the list of Events in the given genre as AnyObject
        let eventDataObtained: AnyObject? = appDelegate.dict_MyEvents[givenEventId] as AnyObject
        
        // Typecast the AnyObject to Swift Array of String objects
        var eventData = eventDataObtained! as! [String]
        
        // Set the cell title to be the Event title
        cell.eventTitleLabel.text = eventData[0]
        
        // Set Event Image
        let eventImageUrl = eventData[9]
        if eventImageUrl == "null"{
            cell.eventImageView.image = UIImage(named: "imageUnavailable.png")
        }
        else{
            if let url = URL(string: eventImageUrl){
                let eventImageData = try? Data(contentsOf: url)
                
                if let imageData = eventImageData {
                    cell.eventImageView.image = UIImage(data: imageData)
                } else {
                    cell.eventImageView.image = UIImage(named: "imageUnavailable.png")
                }
            }
            else{
                cell.eventImageView.image = UIImage(named: "imageUnavailable.png")
            }
        }
        
        // Set event location
        cell.eventLocationLabel.text = eventData[5]
        
        // Set event start time
        cell.eventStartTimeLabel.text = eventData[4]
        
        return cell
    }
    
    //-------------------------------
    // Allow Editing of Rows (Events)
    //-------------------------------
    
    // We allow each row (Event) of the table view to be editable, i.e., deletable or movable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    //---------------------
    // Delete Button Tapped
    //---------------------
    
    // This is the method invoked when the user taps the Delete button in the Edit mode
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {   // Handle the Delete action
            
            // Obtain the name of the genre of the Event to be deleted
            let eventId = eventIds[(indexPath as NSIndexPath).row]
            
            
            // Remove the selected event using its unique event id
            appDelegate.dict_MyEvents.removeObject(forKey: eventId)
            
            // Obtain the updated dictionary as a regular swift dictionary with the same format
            let tempDict = appDelegate.dict_MyEvents as? [String:[String]]
            
            // Sort the dictionary by event date, which is the
            let sorted = tempDict!.sorted(by: {($0.value[3]) < ($1.value[3])}).map{$0.key}
            
            eventIds = sorted
            
            // Reload the rows of the Table View
            tableView.reloadData()
        }
    }
    
    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    //--------------------------
    // Selection of a Event (Row)
    //--------------------------
    
    // Tapping a row (city) displays the trailer of the Event
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        eventDataToPass = []
        
        // Obtain the name of the genre of the selected Event
        let selectedEventId = eventIds[(indexPath as NSIndexPath).row]
        
        // Obtain the data for the selected event
        eventDataToPass = appDelegate.dict_MyEvents.value(forKey: selectedEventId) as! [String]
        
        // Perform the segue named Event Trailer
        performSegue(withIdentifier: "Event Details", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "Event Details" {
            
            // Obtain the object reference of the destination view controller
            let eventDetailsViewController: EventDetailsViewController = segue.destination as! EventDetailsViewController
            
            //Pass the data object to the destination view controller object
            eventDetailsViewController.eventDataObtained = eventDataToPass
            
        }
    }
}
