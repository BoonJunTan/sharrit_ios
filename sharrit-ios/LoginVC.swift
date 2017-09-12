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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: SharritButton) {
        
        /*
        let preferences = UserDefaults.standard
        let loginData: [String: Any] = ["mobileNo": mobileNoTxt.text ?? nil, "password": passwordTxt.text ?? nil]
        let url = "http://example.com"
        
        Alamofire.request(url, method: .post, parameters: loginData).responseJSON {
            response in
            guard response.result.error != nil else {
                return
            }
            if let JSON = (response.result.value as? Dictionary<String, Int>) {
                
                //TODO: Depending on what JSON is return.
                preferences.set(true, forKey: "isUserLoggedIn")
                self.modalTransitionStyle = .crossDissolve
                self.dismiss(animated: true, completion: nil)
            }
        }
        */
        
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: nil)
    }
    
}
