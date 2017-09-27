//
//  BusinessInfoCollectionViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos

class BusinessInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var businessTitle: UILabel!
    @IBOutlet weak var businessRating: CosmosView!
    @IBOutlet weak var businessDate: UILabel!

}
