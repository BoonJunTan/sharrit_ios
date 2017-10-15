//
//  TransactionTableViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionImage: UIImageView!
    @IBOutlet weak var transactionTitle: UILabel!
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var transactionDeposit: UILabel!
    @IBOutlet weak var transactionUsage: UILabel!
    @IBOutlet weak var transactionUsageView: UIView!
    @IBOutlet weak var transactionStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
