//
//  LoginAndSignUpVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CountryPicker

class LoginVC: UIViewController, CountryPickerDelegate {
    
    @IBOutlet weak var mobileNoTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var resendVerfication: UIButton!
    
    @IBOutlet weak var mobileCountryBtn: SharritButton!
    @IBOutlet weak var mobileCountryCode: CountryPicker!
    @IBOutlet weak var mobileCountryView: UIView!
    var currentCountry = "SG"
    var currentSelectedCode = ""
    
    @IBOutlet weak var forgetPasswordView: UIView! // First View
    
    @IBOutlet weak var forgetNo: UITextField!
    @IBOutlet weak var sendNoView: UIView! // Second View
    
    @IBOutlet weak var sendPasswordView: UIView! // Third View
    
    @IBOutlet weak var activationView: UIView!
    
    @IBOutlet weak var banView: UIView!
    
    var loginEmpty:Bool = true {
        didSet {
            errorLabel.isHidden = !loginEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileCountryCode.countryPickerDelegate = self
        mobileCountryCode.showPhoneNumbers = true
        mobileCountryCode.setCountry(currentCountry)
        mobileCountryView.isHidden = true
        
        errorLabel.isHidden = true
        verificationView.isHidden = true
        forgetPasswordView.isHidden = true
        sendNoView.isHidden = true
        sendPasswordView.isHidden = true
        activationView.isHidden = true
        banView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        currentSelectedCode = phoneCode
    }
    
    @IBAction func mobileCountryCodeBtn(_ sender: SharritButton) {
        mobileCountryView.isHidden = false
    }
    
    @IBAction func mobileCancelBtn(_ sender: UIButton) {
        mobileCountryCode.setCountry(currentCountry)
        mobileCountryView.isHidden = true
    }
    
    @IBAction func mobileDoneBtn(_ sender: UIButton) {
        mobileCountryBtn.setTitle(currentSelectedCode, for: .normal)
        mobileCountryView.isHidden = true
    }
    
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        verificationView.isHidden = true
    }
    
    @IBAction func dismissForgetView(_ sender: Any) {
        forgetPasswordView.isHidden = true
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        errorLabel.text = "*Mobile and password are required"
        loginEmpty = ((mobileNoTxt.text?.isEmpty)! || (passwordTxt.text?.isEmpty)!)
        
        var mobileCountryCode = mobileCountryBtn.titleLabel?.text
        
        if !loginEmpty {
            let signUpData: [String: Any] = ["phoneNumber": mobileCountryCode! + mobileNoTxt.text!, "password": passwordTxt.text]
            
            let url = "http://localhost:5000/api/auth/userlogin"
            //let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/auth/userlogin"
            
            Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == 1 { // Logged in successfully
                                if let value = response.result.value {
                                    var json = JSON(value)
                                    let userID = json["content"]["userId"].int!
                                    let firstName = json["content"]["firstName"].string!
                                    let lastName = json["content"]["lastName"].string!
                                    let accessToken = json["content"]["accessToken"].string!
                                    let createDate = json["content"]["dateCreated"].string!
                                    
                                    json["content"]["mobile"].stringValue = self.mobileCountryBtn.titleLabel!.text! + self.mobileNoTxt.text!
                                    json["content"]["password"].stringValue = self.passwordTxt.text!
                                    
                                    // This is to save to user preference
                                    var userInfoDict = [String: Any]()
                                    
                                    for (key,subJson):(String, JSON) in json["content"] {
                                        userInfoDict.updateValue(subJson.stringValue, forKey: key)
                                    }
                                    
                                    UserDefaults.standard.set(userInfoDict, forKey: "userInfo")
                                    UserDefaults.standard.synchronize()
                                    
                                    // This is to pass around VC
                                    let userAccount = User(userID: userID, firstName: firstName, lastName: lastName, password: self.passwordTxt.text!, mobile: (self.mobileCountryBtn.titleLabel!.text! + self.mobileNoTxt.text!), accessToken: accessToken, createDate: createDate)
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.user = userAccount
                                }
                                self.performSegue(withIdentifier: "GoBackMain", sender: nil)
                            } else if statusCode == -1 { // Failed
                               
                            } else if statusCode == -2 { // Not active
                                self.activationView.isHidden = false
                            } else if statusCode == -3 { // Banned
                                self.banView.isHidden = false
                            } else if statusCode == -4 { // Not verified
                                self.verificationView.isHidden = false
                                self.resendVerification(mobile: self.mobileNoTxt.text!)
                            } else if statusCode == 0 { // Not Found
                                self.loginEmpty = true
                                self.errorLabel.text = "*Invalid mobile no. or password"
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
    
    @IBAction func resendVertificationPressed(_ sender: UIButton) {
        resendVerification(mobile: mobileNoTxt.text!)
    }
    
    @IBAction func sendPasswordBtnTapped(_ sender: UIButton) {
        sendNoView.isHidden = true
        sendPasswordView.isHidden = false
    }
    
    @IBAction func forgetPasswordBtnTapped(_ sender: UIButton) {
        forgetPasswordView.isHidden = false
        sendNoView.isHidden = false
    }
    
    @IBAction func dismissForgetPassword(_ sender: UIButton) {
        let url = "http://localhost:5000/api/user/forget"
        //let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/user/forget"
        
        Alamofire.request(url, method: .post, parameters: ["phoneNumber": forgetNo.text!], encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .failure(_):
                print("API failure to call")
                break
            default:
                break
            }
        }
        sendPasswordView.isHidden = true
        forgetPasswordView.isHidden = true
    }
    
    func resendVerification(mobile: String) {
        let mobileCountryCode = mobileCountryBtn.titleLabel?.text

        let url = "http://localhost:5000/api/auth/reverify/" + mobileCountryCode! + mobile
        //let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/auth/reverify/" + mobileCountryCode! + mobile
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .failure(_):
                print("Resend Verification API failed")
                break
            default:
                break
            }
        }
    }
    
    @IBAction func resentActivation(_ sender: UIButton) {
        let mobileCountryCode = mobileCountryBtn.titleLabel?.text
        
        let url = "http://localhost:5000/api/auth/activate/" + mobileCountryCode! + mobileNoTxt.text!
        //let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/auth/activate/" + mobileCountryCode! + mobileNoTxt.text!
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .failure(_):
                print("Reactivate Acc API failed")
                break
            default:
                break
            }
        }
    }
    
    @IBAction func dismissActivationView(_ sender: UIButton) {
        activationView.isHidden = true
    }
    
    @IBAction func dismissBanView(_ sender: UIButton) {
        banView.isHidden = true
    }
    
}
