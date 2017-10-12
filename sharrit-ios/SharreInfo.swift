//
//  SharreInfo.swift
//  sharrit-ios
//
//  Created by Boon Jun on 13/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharreInfo: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var sharreDescription: UILabel!
    
    override init(frame: CGrect) {
        super.init(frame: frame)
        let xibView = UINib(nibName: "SharreInfo", bundle: nil).instantiate(withOwner: nil, options:nil)[0] as! UIView
        self.addSubview(xibView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
