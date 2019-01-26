//
//  EventDetailsViewController.swift
//  iSocialize
//
//  Created by Bengi Sevil on 12/5/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit
import EventKit

class EventDetailsViewController: UIViewController {
    
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventDescriptionLabel: UITextView!
    @IBOutlet var eventLocationLabel: UILabel!
    @IBOutlet var eventCategoryLabel: UILabel!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var localNewsButton: UIButton!
    
    //Event data obtained from upstream view controller
    var eventDataObtained = [String]()
    
    // Obtain the object reference of the App Delegate object
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    /*
     Example eventDataObtained
     ["The Book Of Mormon",
     "32.717426",
     "-117.1624216",
     "http://sandiego.eventful.com/events/book-mormon-/E0-001-114645349-0@2019072319?utm_source=apis&utm_medium=apim&utm_campaign=apic",
     "2019-07-23 19:00:00",
     "San Diego Civic Theatre",
     "1100 Third Avenue",
     "California",
     "San Diego",
     "http://d1marr3m5x4iac.cloudfront.net/images/small/I0-001/004/097/144-8.jpeg_/the-book-of-mormon-44.jpeg",
     "It might be hard for some people to believe that the hottest musical on something as dignified as Broadway, is a parody called The Book of Mormon. While some had their reservations (and many still do) about the quality of a play that satirizes a single religion, audiences and critics are applauding the production values, songs, acting, and well-developed plot. Even the Church of Jesus Christ of Latter-day Saints isn\'t condemning the production, only emphasizing the line between fiction and reality. Because The Book of Mormon isn\'t ridiculing Mormonism, it\'s parodying all organized religion; and doing so in true Broadway fashion.",
     "Concerts&amp;Tour Dates"]*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.eventDataPassed = eventDataObtained
        
        eventTitleLabel.text = eventDataObtained[0]
        
        // Set Category
        eventCategoryLabel.text = eventDataObtained[11].components(separatedBy: "&")[0]
        
        // Set event Image
        let eventImageUrl = eventDataObtained[9]
        
        if eventImageUrl == "null"{
            eventImageView.image = UIImage(named: "imageUnavailable-1.png")
        }
        else{
            if let url = URL(string: eventImageUrl) {
                let eventImageData = try? Data(contentsOf: url)
                
                if let imageData = eventImageData {
                    eventImageView.image = UIImage(data: imageData)
                } else {
                    eventImageView.image = UIImage(named: "imageUnavailable-1.png")
                }
            }
            else{
                eventImageView.image = UIImage(named: "imageUnavailable-1.png")
            }
        }
        
        eventDescriptionLabel.text = eventDataObtained[10]
        eventLocationLabel.text = eventDataObtained[8]
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {

    }
    
    
    @IBAction func addToCalendarTapped(_ sender: UIBarButtonItem) {
        
        
        var eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccess(to: .event){ (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                event.title = self.eventDataObtained[0]
                event.startDate = Date()
                event.endDate = Date()
                event.notes = "Thank you for using iSocialize!"
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
                self.showAlertMessage(messageHeader: "Event Saved!", messageBody: "\(self.eventDataObtained[0]) was saved on your calendar!")
            }
            else{
                
                print("failed to save event with error : \(error) or access not granted")
            }
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
    
    
    @IBAction func directionsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "Directions", sender: self)
    }
    
    
    @IBAction func newsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "News", sender: self)
    }
    
}
