//
//  EditProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 17/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = NavBarUI().getNavBar()
    }
    
}
