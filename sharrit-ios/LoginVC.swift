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
    
    var loginEmpty:Bool = true {
        didSet {
            errorLabel.isHidden = !loginEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: SharritButton) {
        loginEmpty = ((mobileNoTxt.text?.isEmpty)! || (passwordTxt.text?.isEmpty)!)
        
        if !loginEmpty {
            
            let preferences = UserDefaults.standard
            let signUpData: [String: Any] = ["phoneNumber": mobileNoTxt.text, "password": passwordTxt.text]
            
            let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/login"
            
            Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    print(response.result.value!)
                    
                    /*
                    from response.result get "accessToken"
                    Key: Authorization
                    Value: "Bearer" + accessToken
                    */
                    
                    preferences.set(true, forKey: "isUserLoggedIn")
                    self.performSegue(withIdentifier: "GoBackMain", sender: nil)
                    break
                case .failure(_):
                    print(response.result.error!)
                    break
                }
            }
            
            
        }
    }
    
}
