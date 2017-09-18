//
//  EditProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 17/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var userFirstName: UITextField!
    @IBOutlet weak var userLastName: UITextField!
    
    // Not available at the moment
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var userEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailView.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userFirstName.text = appDelegate.user?.firstName
        userLastName.text = appDelegate.user?.lastName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = NavBarUI().getNavBar()
    }
    
    @IBAction func saveBtnTapped(_ sender: SharritButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let signUpData: [String: Any] = ["firstName": userFirstName.text, "lastName": userLastName.text]
        
        let url = "http://localhost:5000/api/user/1"// + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .put, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                // Change App Delegate
                appDelegate.user?.firstName = self.userFirstName.text!
                appDelegate.user?.lastName = self.userLastName.text!
                
                // Change User Default
                if var userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
                    userInfo["firstName"] = self.userFirstName.text!
                    userInfo["lastName"] = self.userLastName.text!
                    UserDefaults.standard.set(userInfo, forKey: "userInfo")
                    UserDefaults.standard.synchronize()
                }
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Edit Profile API failed")
                break
            }
        }
    }
    
}
