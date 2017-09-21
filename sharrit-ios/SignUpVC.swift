//
//  SignUpVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import CountryPicker

class SignUpVC: UIViewController, CountryPickerDelegate {

    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var mobileTxt: UITextField!
    
    @IBOutlet weak var mobileCountryCodeBtn: SharritButton!
    @IBOutlet weak var mobileCountryCode: CountryPicker!
    @IBOutlet weak var mobileCountryView: UIView!
    var currentCountry = "SG"
    var currentSelectedCode = ""
    
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var verificationLabel: UILabel!
    
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
        
        mobileTxt.keyboardType = .numberPad
        
        // Setup default country code
        mobileCountryCode.countryPickerDelegate = self
        mobileCountryCode.showPhoneNumbers = true
        mobileCountryCode.setCountry(currentCountry)
        mobileCountryView.isHidden = true
        
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
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        currentSelectedCode = phoneCode
    }
    
    @IBAction func changeCountryBtnPressed(_ sender: SharritButton) {
        mobileCountryView.isHidden = false
    }
    
    @IBAction func countryCancelBtn(_ sender: UIButton) {
        mobileCountryCode.setCountry(currentCountry)
        mobileCountryView.isHidden = true
    }
    
    @IBAction func countryDoneBtn(_ sender: UIButton) {
        mobileCountryCodeBtn.setTitle(currentSelectedCode, for: .normal)
        mobileCountryView.isHidden = true
    }
    
    @IBAction func signUpBtnPressed(_ sender: SharritButton) {
        
        firstNameEmpty = (firstNameTxt.text?.isEmpty)!
        lastNameEmpty = (lastNameTxt.text?.isEmpty)!
        
        passwordEmpty = true
        if (passwordTxt.text?.isEmpty)! {
            passwordError.text = "*Password is required"
        } else if !(RegexCheck().checkMinPassword(password: passwordTxt.text!)) {
            passwordError.text = "*Password has to be at least 8 characters"
        } else {
            passwordEmpty = false
        }
        
        mobileEmpty = true
        if (mobileTxt.text?.isEmpty)! {
            mobileError.text = "*Mobile no. is required"
        } else if !RegexCheck().checkGeneralPhone(phoneNumber: mobileTxt.text!) {
            mobileError.text = "*Please enter valid mobile no."
        } else {
            mobileEmpty = false
        }
        
        if !firstNameEmpty && !lastNameEmpty && !mobileEmpty && !passwordEmpty {
            var mobileCountryCode = mobileCountryCodeBtn.titleLabel?.text
            
            let signUpData: [String: Any] = ["firstName": firstNameTxt.text, "lastName": lastNameTxt.text, "phoneNumber": mobileCountryCode! + mobileTxt.text!, "password": passwordTxt.text]
            
            let url = SharritURL.devURL + "user"
            
            Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    self.verificationView.isHidden = true
                    self.verificationLabel.text = "We have sent you an SMS verification with instructions to join us. Cheers!"
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
                    self.verificationView.isHidden = true
                    self.verificationLabel.text = "An account with this mobile number already existed. Try forgetting password, Cheers!"
                    UIView.animate(withDuration: 5, animations: {
                        self.verificationView.alpha = 0
                    }) { (finished) in
                        self.verificationView.alpha = 1
                        self.verificationView.isHidden = true
                        self.modalTransitionStyle = .crossDissolve
                        self.dismiss(animated: true, completion: nil)
                    }
                    break
                }
            }
        }
    }

    @IBAction func signInBtnPressed(_ sender: UIButton) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true, completion: nil)
    }
    
}
