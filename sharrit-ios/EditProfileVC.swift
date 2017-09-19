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
    @IBOutlet weak var succesfulUpdateView: UIView!
    
    // Not available at the moment
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var userEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailView.isHidden = true
        succesfulUpdateView.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userFirstName.text = appDelegate.user?.firstName
        userLastName.text = appDelegate.user?.lastName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveBtnTapped(_ sender: SharritButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let signUpData: [String: Any] = ["firstName": userFirstName.text, "lastName": userLastName.text]
        
        let url = "http://localhost:5000/api/user/1"
        // let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/user" + String(describing: appDelegate.user!.userID)
        
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
                self.succesfulUpdateView.isHidden = false
                
                UIView.animate(withDuration: 5, animations: {
                    self.succesfulUpdateView.alpha = 0
                }) { (finished) in
                    self.succesfulUpdateView.alpha = 1
                    self.succesfulUpdateView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
                break
            case .failure(_):
                print("Edit Profile API failed")
                break
            }
        }
    }
    
    @IBAction func deactivateBtnTapped(_ sender: SharritButton) {
        let alertController = UIAlertController(title: "Deactivate Account", message:
            "Deactivating your account will disable your profile and other users will not be able to communicate with you.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Deactivate", style: UIAlertActionStyle.default,handler: { action in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let url = "http://localhost:5000/api/auth/deactive/" + String(describing: appDelegate.user!.mobile)
            
            // let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/auth/deactive/" + String(describing: appDelegate.user!.mobile)
            
            Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    print("Disable Profile API failed")
                    break
                }
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
