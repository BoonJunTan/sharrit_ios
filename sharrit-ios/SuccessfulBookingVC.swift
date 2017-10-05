//
//  SuccessfulBookingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 5/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class SuccessfulBookingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}
