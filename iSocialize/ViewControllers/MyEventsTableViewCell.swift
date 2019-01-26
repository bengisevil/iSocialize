//
//  MyEventsTableViewCell.swift
//  iSocialize
//
//  Created by Bengi Sevil on 12/5/18.
//  Copyright © 2018 Jovan Rivera. All rights reserved.
//

import UIKit

class MyEventsTableViewCell: UITableViewCell {
    
    // Instance variables holding the object references of the Table View Cell UI objects created in Storyboard
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventLocationLabel: UILabel!
    @IBOutlet var eventStartTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
