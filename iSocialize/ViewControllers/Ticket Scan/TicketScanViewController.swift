//
//  HomeViewController.swift
//  CodeReader
//
//  Created by Tracy Pan on 9/19/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//


import UIKit
import AVFoundation

class TicketScanViewController: UIViewController {
    
    // User's authorization is required to access the camera
    var cameraUseAuthorizedByUser = false
    
    // Instance variables holding the object references of the UI buttons
    @IBOutlet var readFoodCodeButton: UIButton!
    @IBOutlet var readProductCodeButton: UIButton!
    @IBOutlet var readQRCodeButton: UIButton!
    
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the buttons to show in a rounded rectangle
        
        
//        
//        readProductCodeButton.backgroundColor = UIColor.clear
//        readProductCodeButton.layer.cornerRadius = 20
//        readProductCodeButton.layer.borderWidth = 1
//        readProductCodeButton.layer.borderColor = UIColor.blue.cgColor
        
        
        
        askUserPermissionToUseCamera()
    }
    
    
    /*
     -----------------------------------------------
     MARK: - Ask User's Permission to Use the Camera
     -----------------------------------------------
     */
    func askUserPermissionToUseCamera() {
        
        /*
         The requestAccess method prompts the user in a dialog asking:
         
         Part 1: "CodeReader" Would Like to Access the Camera
         Part 2: CodeReader requires the use of your Camera to scan a bar code.
         
         You must enter Part 2 as the value of the "Privacy - Camera Usage Description"
         in the Info.plist file.
         
         The requestAccess method will execute ONLY ONCE after the user launches the app
         for the first time upon which an entry is created for the app in the Settings.
         
         The requestAccess method checks to see if there is a record for the app in the
         Settings. If there is one, then it will not execute.
         */
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            
            /* "The response parameter is a block whose sole parameter [named here as permissionGranted]
             indicates whether the user granted or denied permission to record." [Apple]
             */
            permissionGranted in
            
            if permissionGranted {
                
                self.cameraUseAuthorizedByUser = true
                
            } else {
                self.cameraUseAuthorizedByUser = false
            }
        })
    }
    
    
    /*
     -------------------------------
     MARK: - Read Code Button Tapped
     -------------------------------
     */
    @IBAction func readCodeButtonTapped(_ sender: UIButton) {
        
        /*
         The user may have changed the permission to access camera in Settings.
         Therefore, we need to check the authorization status to access the camera.
         */
        checkCameraUseAuthorization()
        
        if cameraUseAuthorizedByUser {
            
            // Each Read Code UIButton object is given a tag number in the Storyboard
            // Read Product Code button tapped
            
            // Set the Storyboard ID of ProductBarcodeReaderViewController under the Identity Inspector to "ProductBarCodeReader"
            let productBarCodeReaderViewController = storyboard?.instantiateViewController(withIdentifier: "ProductBarCodeReader")
            navigationController?.popToViewController(productBarCodeReaderViewController!, animated: true)
            
            
            
            
            
        } else {
            showAlertMessage(messageTitle: "Permission Required!",
                             messageContent: "In the Settings app, please allow CodeReader to access Camera, which is required to scan a bar code!")
        }
        
    }
    
    
    /*
     ---------------------------------------------
     MARK: - Check Camera Use Auhtorization Status
     ---------------------------------------------
     */
    func checkCameraUseAuthorization() {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch authorizationStatus {
            
        case .authorized:
            cameraUseAuthorizedByUser = true
            
        case .denied:
            cameraUseAuthorizedByUser = false
            showAlertMessage(messageTitle: "Unable to Scan!",
                             messageContent: "In the Settings app, please allow CodeReader to access Camera, which is required to scan a bar code!")
            
        case .notDetermined:
            cameraUseAuthorizedByUser = false
            showAlertMessage(messageTitle: "Unable to Scan!",
                             messageContent: "In the Settings app, please allow CodeReader to access Camera, which is required to scan a bar code!")
            
        default:
            cameraUseAuthorizedByUser = false
            showAlertMessage(messageTitle: "Unable to Scan!",
                             messageContent: "In the Settings app, please allow CodeReader to access Camera, which is required to scan a bar code!")
        }
    }
    
    
    /*
     --------------------------
     MARK: - Show Alert Message
     --------------------------
     */
    func showAlertMessage(messageTitle: String, messageContent: String) {
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: messageTitle, message: messageContent, preferredStyle: .alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
}



