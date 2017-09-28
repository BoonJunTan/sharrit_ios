//
//  TransactionVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import ImageSlideshow

class TransactionVC: UIViewController {

    @IBOutlet weak var sharreImage: ImageSlideshow!
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var sharrorLabel: UILabel!
    @IBOutlet weak var transactionStatus: UILabel!
    @IBOutlet weak var transactionDepositUsageFee: UILabel!
    @IBOutlet weak var transactionUnit: UILabel!
    @IBOutlet weak var sharreCategory: UILabel!
    @IBOutlet weak var sharreDescription: UITextView!
    
    @IBOutlet weak var receiptNumber: UILabel!
    @IBOutlet weak var qRCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sharreImage.setImageInputs([ImageSource(image: #imageLiteral(resourceName: "carousel1")), ImageSource(image: #imageLiteral(resourceName: "carousel2")), ImageSource(image: #imageLiteral(resourceName: "carousel3"))])
        sharreImage.contentScaleMode = .scaleToFill
        sharreImage.slideshowInterval = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
