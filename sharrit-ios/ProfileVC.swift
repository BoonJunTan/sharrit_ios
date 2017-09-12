//
//  ProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutBtnPressed(_ sender: SharritButton) {
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        
        let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        loginVC.modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })

    }
    
}
