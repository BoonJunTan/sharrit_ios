//
//  SharesInfoCollectionViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos

class SharesInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sharesImage: UIImageView!
    @IBOutlet weak var sharesTitle: UILabel!
    @IBOutlet weak var sharesPrice: UILabel!
    @IBOutlet weak var sharesDeposit: UILabel!
    @IBOutlet weak var sharesRating: CosmosView!
    
}
