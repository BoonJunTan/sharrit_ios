//
//  SharesInfoTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharesInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var sharesImage: UIImageView!
    @IBOutlet weak var sharesTitle: UILabel!
    @IBOutlet weak var sharesDate: UILabel!
    @IBOutlet weak var sharesDeposit: UILabel!
    @IBOutlet weak var sharesUsage: UILabel!
    
    @IBOutlet weak var depositStatusView: UIView!
    @IBOutlet weak var depositStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
