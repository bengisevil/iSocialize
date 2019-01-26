//
//  ProductDataTableViewCell.swift
//  CodeReader
//
//  Created by Tracy Pan on 9/19/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//


import UIKit

class ProductDataTableViewCell: UITableViewCell {
    
    // Instance variables holding the object references of the Table View Cell UI objects
    @IBOutlet var productSellerName: UILabel!
    @IBOutlet var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

