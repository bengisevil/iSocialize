//
//  ProductBarcodeReaderViewController.swift
//  CodeReader
//
//  Created by Tracy Pan on 9/19/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//



import UIKit
import AVFoundation

class ProductBarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    /*
     -----------------------------------------------------------------------------------------------
     Product barcode data are obtained from Semantics3 API, http://docs.semantics3.com/v1.0/docs
     To use this API, sign up at https://semantics3.com/ as a developer and obtain your own API Key.
     Be aware that Dr. Balci's API key below allows maximum 500 Pull API calls per day.
     -----------------------------------------------------------------------------------------------
     */
    var semanatics3APIKey: String = "SEM3DB614918D03370CFD64965EC546337EC"
    
    // Declare an instance variable as an object reference pointing to an NSMutableData object
    var productDataObtainedFromAPI = NSMutableData()
    
    // Data to pass to downstream view controller
    var productName = ""
    var productData = [String: AnyObject]()
    
    /*
     Create an AVCaptureSession object and store its object reference into "avCaptureSession" constant.
     AVCaptureSession object is used to coordinate the flow of data from AV input devices to outputs.
     */
    let avCaptureSession = AVCaptureSession()
    
    /*
     "AVCaptureVideoPreviewLayer is a subclass of CALayer that you use to display video
     as it is being captured by an input device.
     */
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Declare an instance variable to hold the object reference of a UIImageView object
    var scanningRegionView: UIImageView!
    
    // Declare an instance variable to hold the object reference of a UIImageView object
    var scanningCompleteView: UIImageView!
    
    // Declare and initialize view width and height
    var viewWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtain the Height and Width of the view
        viewHeight = view.frame.height
        viewWidth = view.frame.width
        
        constructScanningRegionView()
        
        constructScanningCompleteView()
        
        // Set the default AV Capture Device to capture data of media type video
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let captureDeviceInput: AVCaptureDeviceInput? = try AVCaptureDeviceInput(device: captureDevice!) as AVCaptureDeviceInput
            
            // AV Capture input device is initialized and ready
            avCaptureSession.addInput(captureDeviceInput!)
            
        } catch let error as NSError {
            // An NSError object contains detailed error information than is possible using only an error code or error string
            
            // AV Capture input device failed
            
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "AVCaptureDeviceInput Failed!",
                                                    message: "An error occurred during AV capture device input: \(error)",
                preferredStyle: UIAlertController.Style.alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        /*
         Create an AVCaptureMetadataOutput object and store its object reference into local constant "output".
         "An AVCaptureMetadataOutput object intercepts metadata objects emitted by its associated capture
         connection and forwards them to a delegate object for processing."
         */
        let output = AVCaptureMetadataOutput()
        
        /*
         Set self to be the delegate to notify when new metadata objects become available.
         Set dispatch queue on which to execute the delegate’s methods.
         */
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Set the rectangle of interest to match the bounding box we drew above
        output.rectOfInterest = CGRect(x: 0.45, y: 0.1, width: 0.1, height: 0.8)
        
        avCaptureSession.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // Add a preview so the user can see what the camera is detecting
        previewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession) as AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Move the scanningRegionView subview so that it appears on top of its siblings
        view.bringSubviewToFront(scanningRegionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Start the AV Capture Session running. It will run until it is stopped later.
        avCaptureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Reinitialize productData
        productData = [String: AnyObject]()
        
        // Move the scanningCompleteView subview so that it appears behind its siblings
        self.view.sendSubviewToBack(scanningCompleteView)
    }
    
    /*
     --------------------------------------
     MARK: - Construct Scanning Region View
     --------------------------------------
     */
    func constructScanningRegionView() {
        
        // Create an image view object to show the entire view frame as the scanning region
        scanningRegionView = UIImageView(frame: view.frame)
        
        // Create a bitmap-based graphics context as big as the scanning region and make it the Current Context
        UIGraphicsBeginImageContext(scanningRegionView.frame.size)
        
        // Draw the entire image in the specified rectangle, which is the entire view frame (scanning region)
        scanningRegionView.image?.draw(in: CGRect(x: 0, y: 0, width: scanningRegionView.frame.width, height: scanningRegionView.frame.height))
        
        /*
         Display a left bracket "[" and right bracket "]" to designate the area of scanning.
         For an example view size of viewWidth = 414 and viewHeight = 736.
         Origin (x, y) = (0, 0) is at the left bottom corner.
         
         (41,442) ------- (62,442)               (352,442) ------- (373,442)
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         (41,294) ------- (62,294)               (352,294) ------- (373,294)
         */
        
        //-------------------------------------------
        //         Draw the Left Bracket
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (62, 294)
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x:  viewWidth * 0.15, y: viewHeight * 0.4))
        
        // Draw bracket bottom line from (62, 294) to (41, 294)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.1, y: viewHeight * 0.4))
        
        // Draw bracket left line from (41, 294) to (41, 442)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.1, y: viewHeight * 0.6))
        
        // Draw bracket top line from (41, 442) to (62, 442)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.15, y: viewHeight * 0.6))
        
        //-------------------------------------------
        //         Draw the Right Bracket
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (352,294)
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x:  viewWidth * 0.85, y: viewHeight * 0.4))
        
        // Draw bracket bottom line from (352,294) to (373, 294)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.9, y: viewHeight * 0.4))
        
        // Draw bracket right line from (373, 294) to (373, 442)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.9, y: viewHeight * 0.6))
        
        // Draw bracket top line from (373, 442) to (352, 442)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.85, y: viewHeight * 0.6))
        
        //-------------------------------------------
        //    Set Properties of the Bracket Lines
        //-------------------------------------------
        
        // Set the bracket lines with a squared-off end
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.butt)
        
        // Set the bracket line width to 5
        UIGraphicsGetCurrentContext()?.setLineWidth(5)
        
        // Set the bracket line color to light gray
        UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.lightGray.cgColor)
        
        // Set the bracket line blend mode to be normal
        UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
        
        // Set the bracket line stroke path
        UIGraphicsGetCurrentContext()?.strokePath()
        
        // // Set the bracket line Antialiasin off
        UIGraphicsGetCurrentContext()?.setAllowsAntialiasing(false)
        
        //-------------------------------------------
        //    Draw the Red Line as the Focus Line
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (62,368)
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x:  viewWidth * 0.15, y: viewHeight * 0.5))
        
        // Draw the focus line from (62,368) to (352, 368)
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.85, y: viewHeight * 0.5))
        
        // Set the properties of the red focus line
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.butt)
        UIGraphicsGetCurrentContext()?.setLineWidth(1)
        UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.red.cgColor)
        UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
        UIGraphicsGetCurrentContext()?.strokePath()
        
        // Set the image based on the contents of the current bitmap-based graphics context to be the scanningRegionView's image
        scanningRegionView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Remove the current bitmap-based graphics context from the top of the stack
        UIGraphicsEndImageContext()
        
        // Add the newly created scanningRegionView as a subview of the current view
        view.addSubview(scanningRegionView)
    }
    
    /*
     ----------------------------------------
     MARK: - Construct Scanning Complete View
     ----------------------------------------
     */
    func constructScanningCompleteView() {
        
        // Create an image view object to show the entire view frame as the scanning complete view
        scanningCompleteView = UIImageView(frame: view.frame)
        
        // Create a bitmap-based graphics context as big as the view frame size and make it the Current Context
        UIGraphicsBeginImageContext(scanningCompleteView.frame.size)
        
        // Draw the entire image in the specified rectangle, which is the entire view frame
        scanningCompleteView.image?.draw(in: CGRect(x: 0, y: 0, width: scanningCompleteView.frame.width, height: scanningCompleteView.frame.height))
        
        //-------------------------------------------
        //         Draw the Left Bracket
        //-------------------------------------------
        
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x:  viewWidth * 0.15, y: viewHeight * 0.4))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.1, y: viewHeight * 0.4))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:   viewWidth * 0.1, y: CGFloat(Int(viewHeight * 0.6))))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:   viewWidth * 0.15, y: CGFloat(Int(viewHeight * 0.6))))
        
        //-------------------------------------------
        //         Draw the Right Bracket
        //-------------------------------------------
        
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x:  viewWidth * 0.85, y: CGFloat(Int(viewHeight * 0.4))))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:  viewWidth * 0.9, y: CGFloat(Int(viewHeight * 0.4))))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:   viewWidth * 0.9, y: CGFloat(Int(viewHeight * 0.6))))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x:   viewWidth * 0.85, y: CGFloat(Int(viewHeight * 0.6))))
        
        //-------------------------------------------
        //    Set Properties of the Bracket Lines
        //-------------------------------------------
        
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.butt)
        UIGraphicsGetCurrentContext()?.setLineWidth(5)
        UIGraphicsGetCurrentContext()?.setStrokeColor(UIColor.green.cgColor)
        UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
        UIGraphicsGetCurrentContext()?.strokePath()
        UIGraphicsGetCurrentContext()?.setAllowsAntialiasing(false)
        
        // Set the image based on the contents of the current bitmap-based graphics context to be the scanningCompleteView's image
        scanningCompleteView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Remove the current bitmap-based graphics context from the top of the stack
        UIGraphicsEndImageContext()
        
        // Add the newly created scanningCompleteView as a subview of the current view
        view.addSubview(scanningCompleteView)
        
        // Move the scanningCompleteView subview so that it appears behind its siblings
        view.sendSubviewToBack(scanningCompleteView)
    }
    
    /*
     --------------------------------------------------------------
     MARK: - AVCaptureMetadataOutputObjectsDelegate Protocol Method
     --------------------------------------------------------------
     */
    
    // Informs the delegate (self) that the capture output object emitted new metadata objects, i.e., a known barcode is read
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        var barcodeRead = ""
        
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            
            // Obtain the first metadata object as the scan
            let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            // The scan object's String value is the barcode value read
            barcodeRead = scan.stringValue!
            
            // Move the scanningCompleteView subview so that it appears on top of its siblings
            self.view.bringSubviewToFront(scanningCompleteView)
            
            // Stop the AV Capture Session running
            self.avCaptureSession.stopRunning()
            
        } else {
            print("Unrecognized Barcode!")
            return
        }
        
        // If the barcode was read, call the searchBarcodeOnSemantics function
        if barcodeRead != "" {
            searchBarcodeOnSemantics(barcodeRead)
        }
    }
    
    /*
     --------------------------
     MARK: - Barcode Processing
     --------------------------
     */
    func searchBarcodeOnSemantics(_ barcodeValue: String) {
        
        // Compose the semantics API query with the barcode string
        let semanticsAPIQuery = "https://api.semantics3.com/test/v1/products?q={\"upc\":\"\(barcodeValue)\"}"
        let escapedString = semanticsAPIQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // Create an NSURL object from the semantics API query string
        let url = URL(string: escapedString!)
        
        // Convert the NSURL object to be a mutable (changeable) HTTP request object
        let request = NSMutableURLRequest(url: url!)
        
        // Set the HTTP request method to "GET"
        request.httpMethod = "GET"
        
        // Sets the request's HTTP header field "api_key" to semanatics3APIKey
        request.setValue(semanatics3APIKey, forHTTPHeaderField: "api_key")
        
        // A URLSessionConfiguration object defines the behavior and policies to use when uploading and downloading data using a URLSession object. [Apple]
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        // Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion. [Apple]
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // If an error occurs, present an alert to the user
            if let error = error {
                /*
                 Create a UIAlertController object; dress it up with title, message, and preferred style;
                 and store its object reference into local constant alertController
                 */
                let alertController = UIAlertController(title: "HTTP Connection Failed!",
                                                        message: "Failed with error: \(error.localizedDescription)",
                    preferredStyle: UIAlertController.Style.alert)
                
                // Create a UIAlertAction object and add it to the alert controller
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                // Present the alert controller by calling the presentViewController method
                self.present(alertController, animated: true, completion: nil)
                
            } else if let response = response as? HTTPURLResponse {
                
                // If response is HTTPURLResponse initialize product data
                self.productDataObtainedFromAPI = NSMutableData()
                
                // If request is fulfilled
                if (response.statusCode == 200) {
                    
                    self.productDataObtainedFromAPI.append(data!)
                    
                    //Since UI update should be run in different thread, run this method asycronously
                    DispatchQueue.main.async {
                        self.finishLoading()
                    }
                }
                
            }
        }
        task.resume()
        
    }
    
    
    
    func finishLoading(){
        /*
         NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
         NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
         */
        let jsonDataDictionary = (try! JSONSerialization.jsonObject(with: productDataObtainedFromAPI as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        
        // print(jsonDataDictionary)
        
        /*
         Print the JSON data returned to see its structure. To do this:
         - Connect your iOS device to your computer (iMac, MacBook).
         - Deploy your app to run on your device.
         - While connected to Xcode, run the app on your device, and scan a product barcode.
         - The JSON data will be displayed in Xcode's Debug area.
         
         Example JSON data returned as a Dictionary with Key = Value. Annotation is given within ***.
         Note that {...} represents a Dictionary and (...) represents an Array.
         
         { *** JSON Dictionary START ***
         code = OK;
         offset = 0;
         results = ( *** results Array START ***
         
         { *** results Dictionary START ***
         
         brand = Avery;
         "cat_id" = 22944;
         category = "Labels & Stickers";
         color = White;
         "created_at" = 1347632164;
         ean = 0072782481605;
         features = {
         Adhesive = "Permanent Self-Adhesive";
         "Compliance, Standards" = "Includes Box Tops for Education coupon";
         "Global Product Type" = "Labels-Address";
         "Label Color(S)" = White;
         "Label Size - Text" = "1 x 2 5/8";
         "Label Special Features" = "Includes Easy PEEL Feature";
         "Labels Per Sheet [Nom]" = 30;
         "Labels Per Unit [Nom]" = 750;
         "Machine Compatibility" = "Inkjet Printers, Laser Printers";
         "Material(S)" = Paper;
         "Package Includes" = "Includes 25 sheets of labels; 30 labels per sheet.";
         "Post-Consumer Recycled Content Percent" = "100 %";
         "Pre-Consumer Recycled Content Percent" = "0 %";
         SellingUnit = Box;
         Shape = Rectangular;
         "Sheets Per Unit [Nom]" = 25;
         "Total Recycled Content Percent [Nom]" = "100 %";
         };
         geo = (
         usa
         );
         gtins = (
         00072782481605
         );
         height = "9.65";
         "images_total" = 0;
         length = "304.80";
         manufacturer = Avery;
         model = 48160;
         mpn = 48160;
         name = "Avery White EcoFriendly Address Labels, 1 x 2.625 Inches, Box of 750 (48160)";
         price = "12.99";
         "price_currency" = USD;
         "sem3_help" = "To view image links and additional merchants for this product, please upgrade your plan";
         "sem3_id" = 2EUayTZmwqouycmQq4oOkK;
         
         sitedetails = ( *** sitedetails Array START ***
         {
         latestoffers = (
         {
         availability = Available;
         currency = USD;
         "firstrecorded_at" = 1424549100;
         id = 1MAqlj3czoEiQS020gOykw;
         isactive = 1;
         "lastrecorded_at" = 1430697600;
         price = "7.99";
         seller = Newegg;
         },
         {
         currency = USD;
         "firstrecorded_at" = 1425179100;
         id = 0jOt81t4AIAS6SgcqC8acW;
         isactive = 1;
         "lastrecorded_at" = 1430697600;
         price = "14.00";
         seller = UnbeatableSale;
         shipping = "1095.00";
         },
         {
         currency = USD;
         "firstrecorded_at" = 1426458100;
         id = 1KlgQExzgS8GCSWgoEmsoM;
         isactive = 0;
         "lastrecorded_at" = 1427093800;
         price = "15.00";
         seller = "Pens N More";
         }
         );
         listprice = "14.99";
         "listprice_currency" = USD;
         name = "newegg.com";
         "recentoffers_count" = 2;
         sku = N82E16848013125;
         url = "http://www.newegg.com/Product/Product.aspx?Item=N82E16848013125";
         },
         {
         latestoffers = (
         {
         availability = Available;
         currency = USD;
         "firstrecorded_at" = 1429882100;
         id = 0EIFC42UsHuIQOK4WigwU2;
         isactive = 1;
         "lastrecorded_at" = 1436568500;
         price = "7.93";
         seller = Walmart;
         },
         {
         availability = Available;
         currency = USD;
         "firstrecorded_at" = 1412978400;
         id = 7mp11x8YkKSk6WemSmyeuS;
         isactive = 0;
         "lastrecorded_at" = 1433093600;
         price = "13.32";
         seller = "LD Products";
         },
         {
         availability = Available;
         currency = USD;
         "firstrecorded_at" = 1412978400;
         id = 5g3jBU0RmqsOkWMGQWU6g0;
         isactive = 0;
         "lastrecorded_at" = 1433093600;
         price = "13.52";
         seller = "Build.com";
         }
         );
         name = "walmart.com";
         "recentoffers_count" = 1;
         sku = 10988685;
         url = "http://www.walmart.com/ip/10988685";
         },
         {
         latestoffers = (
         {
         availability = Available;
         currency = USD;
         "firstrecorded_at" = 1425955700;
         id = 1RV5ofDf9c2Caeiws4uo8Y;
         isactive = 1;
         "lastrecorded_at" = 1425955700;
         price = "12.99";
         seller = "Sears Brands, LLC.";
         }
         );
         name = "kmart.com";
         "recentoffers_count" = 1;
         sku = 025V043890487000P;
         url = "http://www.kmart.com/avery-eco-friendly-labels-1-x-2-5-8/p-025V043890487000P";
         }
         
         ); *** sitedetails Array END ***
         
         size = "1 x 2 5/8";
         upc = 072782481605;
         "updated_at" = 1436568575;
         "variation_secondaryids" = (
         50T1A0p3sO24Qme6wkK2UW
         );
         weight = "308442.81";
         width = "239.78";
         
         } *** results Dictionary END ***
         
         ); *** results Array END ***
         
         "results_count" = 1;
         "total_results_count" = 1;
         
         } *** JSON Dictionary END ***
         
         */
        
        //------------------------------------------------------------------
        // Examine the structure of the JSON data in the example given above
        //------------------------------------------------------------------
        
        // Obtain the "results" array from the JSON dictionary data.
        let resultsArray = jsonDataDictionary["results"] as! NSArray
        
        // If the "results" array is empty, alert the user
        if resultsArray.count == 0 {
            
            displayErrorMessage()
            return
        }
        
        // Obtain the dictionary contained in the results array
        var resultsDictionary = resultsArray[0] as! [String: AnyObject]
        
        // If the dictionary does not have a key named "sitedetails", it means no sellers are listed
        if !resultsDictionary.keys.contains("sitedetails") {
            
            displayErrorMessage()
            return
        }
        
        // Obtain the product name
        if resultsDictionary.keys.contains("name") {
            
            productName = resultsDictionary["name"] as! String
        }
        else {
            
            productName = "No product name given"
        }
        
        // Obtain the sitedetails array contained in the results dictionary
        let sitedetailsArray = resultsDictionary["sitedetails"] as! NSArray
        
        // If no sellers are listed, alert the user
        if sitedetailsArray.count == 0 {
            
            displayErrorMessage()
            return
        }
        
        // For each seller, obtain the product name, seller's URL, and seller's price
        for i in 0 ..< sitedetailsArray.count {
            
            var sitedetailsDictionary = sitedetailsArray[i] as! [String: AnyObject]
            let keys = sitedetailsDictionary.keys
            
            if keys.contains("name") {
                
                let sellerName = sitedetailsDictionary["name"] as! String
                var resultsArray = ["", ""]
                
                if keys.contains("url") {
                    
                    let url = sitedetailsDictionary["url"] as! String
                    if (url != "") {
                        resultsArray[1] = url
                    }
                }
                
                if keys.contains("latestoffers") {
                    
                    let latestOffersArray = sitedetailsDictionary["latestoffers"] as! NSArray
                    var price = 0.0
                    
                    // If multiple prices are listed, obtain the lowest price
                    for j in 0 ..< latestOffersArray.count {
                        
                        var listingDictionary = latestOffersArray[j] as! [String: AnyObject]
                        if listingDictionary.keys.contains("price") {
                            
                            let newPrice = (listingDictionary["price"] as! NSString).doubleValue
                            if(price == 0 || newPrice < price) {
                                
                                price = newPrice
                            }
                        }
                    }
                    
                    if (price.description != "0.0") {
                        
                        resultsArray[0] = price.description
                    }
                }
                
                // Add the pricing data to productData to be passed to the downstream view controller
                productData.updateValue(resultsArray as AnyObject, forKey: sellerName)
            }
        }
        
        // Segue downstream to show results
        performSegue(withIdentifier: "Product Data", sender: self)
        
    }
    
    
    
    func displayErrorMessage() {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "Product Data Unavailable!",
                                                message: "No results found for the barcode scanned.",
                                                preferredStyle: UIAlertController.Style.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            
            self.view.sendSubviewToBack(self.scanningCompleteView)
            self.avCaptureSession.startRunning()
        }))
        
        // Present the alert controller by calling the presentViewController method
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Product Data" {
            
            let productDataTableViewController = segue.destination as! ProductDataTableViewController
            
            // Pass the product name and data to the downstream view controller
            productDataTableViewController.productName = self.productName
            productDataTableViewController.productData = self.productData
        }
    }
}

