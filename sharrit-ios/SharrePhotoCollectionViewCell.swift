//
//  SharrePhotoCollectionViewCell.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharrePhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sharreImage: UIImageView!
    @IBOutlet weak var sharreLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        sharreImage.image = #imageLiteral(resourceName: "add")
        sharreImage.contentMode = .center
        cancelBtn.isHidden = true
    }
    
}
