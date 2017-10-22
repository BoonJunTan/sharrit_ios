//
//  ReputationTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class ReputationTableViewCell: UITableViewCell {

    @IBOutlet weak var sharreImage: UIImageView!
    @IBOutlet weak var transactionTitle: UILabel!
    @IBOutlet weak var transactionReview: UILabel!
    @IBOutlet weak var transactionRating: CosmosView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
