//
//  SearchedEventDetailsViewController.swift
//  iSocialize
//
//  Created by Jovan R on 11/15/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit
import AVFoundation

class SearchedEventDetailsViewController: UIViewController {

    var eventDataPassed = [String:String]()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var stopTimeLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    var map_info_to_be_passed = [String:String]()
    var mapData = ["", "", ""]
    
    @IBOutlet var mapButton: UIButton!
    

    @IBAction func showOnMap_ButtonTapped(_ sender: UIButton) {
        
        
        mapData[0] = eventDataPassed["longitude"]!
        mapData[1] = eventDataPassed["latitude"]!
        mapData[2] = eventDataPassed["title"]!
        performSegue(withIdentifier: "map direction", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any!){
        if segue.identifier == "map direction"{
           
            let locationViewController: LocationViewController  = segue.destination as!  LocationViewController
            locationViewController.websitelink = mapData
        }
        
    }
    
    // Declare a speechSynthesizer
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // Declare playButton as an Optional instance variable to hold the object reference of a UIBarButtonItem object
    var playButton: UIBarButtonItem?
    
    // Declare pauseButton as an Optional instance variable to hold the object reference of a UIBarButtonItem object
    var pauseButton: UIBarButtonItem?
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    
    //--------------
    // View Did Load
    //--------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a Pause button to be placed on the left corner of the navigation bar
        pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(pauseButtonTapped))
        
        // Create a Play button to be placed on the left corner of the navigation bar
        playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(playButtonTapped))
        
        // Place the Play button on the right corner of the navigation bar
        self.navigationItem.rightBarButtonItem = playButton
        
        // -- Set labels --
        titleLabel.text = eventDataPassed["title"]
        
        // Set Event Image
        let eventImageUrl = eventDataPassed["imageURL"]
        if eventImageUrl == "null"{
            eventImageView.image = UIImage(named: "imageUnavailable.png")
        }
        else{
            if let url = URL(string: eventImageUrl!){
                let eventImageData = try? Data(contentsOf: url)
                
                if let imageData = eventImageData {
                    eventImageView.image = UIImage(data: imageData)
                } else {
                    eventImageView.image = UIImage(named: "imageUnavailable.png")
                }
            }
            else{
                eventImageView.image = UIImage(named: "imageUnavailable.png")
            }
        }
        
        descriptionTextView.text = eventDataPassed["description"]
        
        categoryLabel.text = eventDataPassed["category"]
        
        locationLabel.text = eventDataPassed["venue_address"]
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy HH:mm"
        
        let start_time = eventDataPassed["start_time"]
        if let date = dateFormatterGet.date(from: start_time!) {
            startTimeLabel.text = dateFormatterPrint.string(from: date)
        }
        
        let stop_time = eventDataPassed["stop_time"]
        if let date = dateFormatterGet.date(from: stop_time!) {
            stopTimeLabel.text = dateFormatterPrint.string(from: date)
        }
        
        countryLabel.text = eventDataPassed["country_name"]
        
        regionLabel.text = eventDataPassed["region_name"]
        
        cityLabel.text = eventDataPassed["city_name"]
        // -- End Set Labels --
        
    }
    
    //--------------------
    // View Will Disappear
    //--------------------
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Place the Play button
        self.navigationItem.rightBarButtonItem = playButton
        
        // If the created audio player is playing, stop playing
        if speechSynthesizer.isSpeaking {
            
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)    // Stop playing the audio file
        }
    }
    
    //--------------------
    // Play button pressed
    //--------------------
    @objc func playButtonTapped(_ sender: Any) {
        // Replace the Play button with Pause button
        self.navigationItem.rightBarButtonItem = pauseButton
        
        // If it not currently speaking, start speaking, otherwise continue where left off
        if !speechSynthesizer.isSpeaking {
            let speechUtterance = AVSpeechUtterance(string: descriptionTextView.text)
            speechSynthesizer.speak(speechUtterance)
            
        }
        else{
            speechSynthesizer.continueSpeaking()
        }
    }
    
    //--------------------
    // Pause button pressed
    //--------------------
    @objc func pauseButtonTapped(_ sender: Any) {
        // Replace the Pause button with Play button
        self.navigationItem.rightBarButtonItem = playButton
        
        // Pause speaking the text
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
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
