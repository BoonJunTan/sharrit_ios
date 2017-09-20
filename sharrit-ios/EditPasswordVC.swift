//
//  EditPasswordVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 18/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class EditPasswordVC: UIViewController {

    @IBOutlet weak var oldPasswordTxt: UITextField!
    @IBOutlet weak var newPasswordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var succesfulUpdateView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMsgLabel.text = " "
        
        succesfulUpdateView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveBtnTapped(_ sender: SharritButton) {
        if (oldPasswordTxt.text?.isEmpty)! || (newPasswordTxt.text?.isEmpty)! || (confirmPasswordTxt.text?.isEmpty)! {
            errorMsgLabel.text = "*Please fill up old, new and confirm password"
        } else if newPasswordTxt.text! != confirmPasswordTxt.text! {
            errorMsgLabel.text = "*New and confirm password mismatch"
        } else {
            errorMsgLabel.text = " "
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let signUpData: [String: Any] = ["firstName": appDelegate.user!.firstName, "lastName": appDelegate.user!.lastName, "password" : newPasswordTxt.text!, "oldPassword" : oldPasswordTxt.text!]
            
            let url = SharritURL.devURL + "user/" + String(describing: appDelegate.user!.userID)
            
            Alamofire.request(url, method: .put, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == -1 {
                                self.errorMsgLabel.text = "*Old password is invalid, please retry."
                            } else {
                                // Change App Delegate
                                appDelegate.user?.password = self.newPasswordTxt.text!
                                
                                // Change User Default
                                if var userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
                                    userInfo["password"] = self.newPasswordTxt.text!
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
                            }
                        }
                    }
                    break
                case .failure(_):
                    print("Edit Password API failed")
                    break
                }
            }
        }
    }
    
}
