//
//  LoginAndSignUpVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController {
    
    @IBOutlet weak var mobileNoTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var verificationView: UIView!
    
    var loginEmpty:Bool = true {
        didSet {
            errorLabel.isHidden = !loginEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        verificationView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        verificationView.isHidden = true
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        errorLabel.text = "*Mobile and password are required"
        loginEmpty = ((mobileNoTxt.text?.isEmpty)! || (passwordTxt.text?.isEmpty)!)
        
        if !loginEmpty {
            let preferences = UserDefaults.standard
            let signUpData: [String: Any] = ["phoneNumber": mobileNoTxt.text, "password": passwordTxt.text]
            
            let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/login"
            
            Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    if let JSON = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = JSON["status"] as? Int {
                            if statusCode == 1 {
                                preferences.set(true, forKey: "isUserLoggedIn")
                                self.performSegue(withIdentifier: "GoBackMain", sender: nil)
                            } else if statusCode == -1 {
                                self.loginEmpty = true
                                self.errorLabel.text = "*Invalid mobile no. or password"
                            } else {
                                self.verificationView.isHidden = false
                            }
                        }
                    }
                    break
                case .failure(_):
                    self.loginEmpty = true
                    self.errorLabel.text = "*Invalid mobile no. or password"
                    break
                }
            }
        }
    }
    
}
