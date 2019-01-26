//
//  LocationViewController.swift
//  iSocialize
//
//  Created by Tracy Pan on 12/5/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit
import MapKit
class LocationViewController: UIViewController, MKMapViewDelegate {
    
var websitelink = ["", "", ""]
    // Instance variable holding the object reference of the Map View UI object
    @IBOutlet var location_map: MKMapView!
    
    // Country name and data are set by the upstream view controller
    var locationTitle: String = ""
   
    
    /*
     countryData[0] = Country Flag Image Filename
     countryData[1] = Country's population
     countryData[2] = Country's capital city name
     countryData[3] = Country Name
     countryData[4] = Latitude
     countryData[5] = Longitude
     countryData[6] = Span
     countryData[7] = Country's website URL
     */
    
    // The following are needed to display the country map
    var latitude:   Double = 0.0
    var longitude:  Double = 0.0
    var span:       Double = 0.0
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("location data is", websitelink)
        locationTitle = websitelink[2]
        
        // Since the latitude, longitude, and span are given as String in the plist file,
        // they need to be converted to Double as required to display the map.
        
        latitude = Double((websitelink[1] as NSString).doubleValue)
        longitude = Double((websitelink[0] as NSString).doubleValue)
//        span = Double((locationData[6] as NSString).doubleValue)
        span = 50000
        /*
         CLLocation usage requires the CoreLocation.framework to be linked to your project.
         Instantiate a geographical location object and initialize it with the country's
         geographical coordinates defined by Latitude and Longitude.
         */
        
        let countryLocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        /*
         MKCoordinateRegion usage requires the MapKit.framework to be linked to your project.
         MKCoordinateRegion is a *data structure*, NOT a class, that defines which portion of the map to display.
         MKCoordinateRegionMakeWithDistance creates a new MKCoordinateRegion with the following parameters:
         
         centerCoordinate = countryLocation.coordinate
         The center point of the new coordinate region.
         
         latitudinalMeters = span
         The amount of north-to-south distance (measured in meters) to use for the span.
         
         longitudinalMeters = span
         The amount of east-to-west distance (measured in meters) to use for the span.
         */
        
        let mapRegion: MKCoordinateRegion? = MKCoordinateRegion.init(center: countryLocation.coordinate, latitudinalMeters: span, longitudinalMeters: span)
        
        // Set the title of the navigation bar to the country name
        title = locationTitle
        
        // Ask the map to display the country region defined above.
        location_map.setRegion(mapRegion!, animated: true)
        
    }
    
    /*
     ------------------------------------------
     MARK: - MKMapViewDelegate Protocol Methods
     ------------------------------------------
     */
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        // Starting to load the map. Show the animated activity indicator in the status bar
        // to indicate to the user that the map view object is busy loading the map.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        // Finished loading the map. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        // An error occurred during the map load. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "Unable to Load the Map for: \(locationTitle)!",
            message: "Error description: \(error.localizedDescription)",
            preferredStyle: UIAlertController.Style.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        present(alertController, animated: true, completion: nil)
    }
    
}


