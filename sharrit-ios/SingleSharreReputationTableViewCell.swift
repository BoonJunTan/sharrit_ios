//
//  SingleSharreReputationTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos

class SingleSharreReputationTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var rating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
