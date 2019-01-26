//
//  ProductDataTableViewController.swift
//  CodeReader
//
//  Created by Tracy Pan on 9/19/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//


import UIKit

class ProductDataTableViewController: UITableViewController {
    
    // Values of these instance variables are set by the upstream view controller
    var productData = [String: AnyObject]()
    var productName = ""
    
    // Other Instance variables
    var sellers = [String]()
    var sellerURL: URL?
    var tableRowHeight: CGFloat = 60
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scene's title
        self.title = productName
        
        // Obtain and sort the sellers data
        sellers = (productData as NSDictionary).allKeys as! [String]
        sellers.sort() {$0 < $1}
    }
    
    /*
     ----------------------------------------------
     MARK: - UITableViewDataSource Protocol Methods
     ----------------------------------------------
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sellers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Product Data Cell") as! ProductDataTableViewCell
        
        let seller = sellers[(indexPath as NSIndexPath).row]
        let productDetails = productData[seller] as! [String]
        
        cell.productSellerName.text = seller
        cell.productPrice.text = "$" + productDetails[0]
        
        return cell
    }
    
    /*
     --------------------------------------------
     MARK: - UITableViewDelegate Protocol Methods
     --------------------------------------------
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let seller = sellers[(indexPath as NSIndexPath).row]
        let productDetails = productData[seller] as! [String]
        
        // Obtain the seller's URL
        sellerURL = URL(string: productDetails[1])
        
        // Check the validity of the seller's URL
        if let _ = sellerURL {
            
            performSegue(withIdentifier: "Product Sellers", sender: self)
            
        } else {
            
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "Seller's Website Unknown!",
                                                    message: "No website URL is provided for the seller.",
                                                    preferredStyle: UIAlertController.Style.alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                
                tableView.deselectRow(at: indexPath, animated: false)
            }))
            
            // Present the alert controller by calling the presentViewController method
            present(alertController, animated: true, completion: nil)
            
            return
        }
    }
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Product Sellers" {
            
            let productSellersViewController = segue.destination as! ProductSellersViewController
            
            // Pass seller's URL and name to the downstream view controller
            productSellersViewController.sellerURL = sellerURL
            productSellersViewController.productName = productName
        }
    }
}

