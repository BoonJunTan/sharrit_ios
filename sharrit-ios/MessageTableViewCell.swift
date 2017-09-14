//
//  MessageTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 14/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileIV: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageDate: UILabel!
    @IBOutlet weak var itemIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
