//
//  NotificationTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 14/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationProfile: UIImageView!
    @IBOutlet weak var notificationDetails: UILabel!
    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationFeedback: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
