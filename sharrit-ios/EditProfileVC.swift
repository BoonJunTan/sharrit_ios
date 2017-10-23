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
    @IBOutlet weak var userAddress: UITextField!
    @IBOutlet weak var succesfulUpdateView: UIView!
    
    // Not available at the moment
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var userGender: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        succesfulUpdateView.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userFirstName.text = appDelegate.user?.firstName
        userLastName.text = appDelegate.user?.lastName
        userAddress.text = appDelegate.user?.address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveBtnTapped(_ sender: SharritButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let signUpData: [String: Any] = ["firstName": userFirstName.text!, "lastName": userLastName.text!, "address": userAddress.text!]
        
        let url = SharritURL.devURL + "user/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .put, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                // Change App Delegate
                appDelegate.user?.firstName = self.userFirstName.text!
                appDelegate.user?.lastName = self.userLastName.text!
                appDelegate.user?.address = self.userAddress.text!
                
                // Change User Default
                if var userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
                    userInfo["firstName"] = self.userFirstName.text!
                    userInfo["lastName"] = self.userLastName.text!
                    userInfo["address"] = self.userAddress.text!
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
            
            let url = SharritURL.devURL + "auth/deactivate/" + String(describing: appDelegate.user!.mobile)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + appDelegate.user!.accessToken,
                "Accept": "application/json" // Need this?
            ]
            
            Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
                    let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
                    loginVC.modalTransitionStyle = .coverVertical
                    self.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion:{
                        if let subviewsCount = self.tabBarController?.view.subviews.count {
                            if subviewsCount > 2 {
                                self.tabBarController?.view.subviews[2].removeFromSuperview()
                            }
                        }
                    })
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
