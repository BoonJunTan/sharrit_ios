//
//  NavBarUI.swift
//  sharrit-ios
//
//  Created by Boon Jun on 17/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class NavBarUI {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getNavBar() -> UIColor {
        
        if ((appDelegate.user?.role == .Sharrie)) {
            return Colours.Blue.sharritBlue
        } else {
            return Colours.Orange.sharrorOrange
        }
    }
    
}
