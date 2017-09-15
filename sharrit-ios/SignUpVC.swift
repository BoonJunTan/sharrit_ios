//
//  SignUpVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire

class SignUpVC: UIViewController {

    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var mobileTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var verificationView: UIView!
    
    @IBOutlet weak var firstNameError: UILabel!
    @IBOutlet weak var lastNameError: UILabel!
    @IBOutlet weak var mobileError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    
    var firstNameEmpty:Bool = true {
        didSet {
            firstNameError.isHidden = !firstNameEmpty
        }
    }
    
    var lastNameEmpty:Bool = true {
        didSet {
            lastNameError.isHidden = !lastNameEmpty
        }
    }
    
    var mobileEmpty:Bool = true {
        didSet {
            mobileError.isHidden = !mobileEmpty
        }
    }
    
    var passwordEmpty:Bool = true {
        didSet {
            passwordError.isHidden = !passwordEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        verificationView.isHidden = true
        firstNameError.isHidden = true
        lastNameError.isHidden = true
        mobileError.isHidden = true
        passwordError.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpBtnPressed(_ sender: SharritButton) {
        
        firstNameEmpty = (firstNameTxt.text?.isEmpty)!
        lastNameEmpty = (lastNameTxt.text?.isEmpty)!
        passwordEmpty = (passwordTxt.text?.isEmpty)!
        
        mobileEmpty = true
        if (mobileTxt.text?.isEmpty)! {
            mobileError.text = "*Mobile no. is required"
        } else if !phoneValidate(with: mobileTxt.text!) {
            mobileError.text = "*Please enter valid mobile no."
        } else {
            mobileEmpty = false
        }
        
        if !firstNameEmpty && !lastNameEmpty && !mobileEmpty && !passwordEmpty {
            verificationView.isHidden = false
            
            let signUpData: [String: Any] = ["firstName": firstNameTxt.text, "lastName": lastNameTxt.text, "phoneNumber": mobileTxt.text, "password": passwordTxt.text]
            
            let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/user"
            
            Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    UIView.animate(withDuration: 5, animations: {
                        self.verificationView.alpha = 0
                    }) { (finished) in
                        self.verificationView.alpha = 1
                        self.verificationView.isHidden = true
                        self.modalTransitionStyle = .crossDissolve
                        self.dismiss(animated: true, completion: nil)
                    }
                    break
                case .failure(_):
                    print(response.result.error!)
                    break
                }
            }
        
        }
    }

    @IBAction func signInBtnPressed(_ sender: UIButton) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
    func phoneValidate(with value: String) -> Bool {
        let PHONE_REGEX = "^[8-9]\\d{7}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
}
