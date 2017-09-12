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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verificationView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpBtnPressed(_ sender: SharritButton) {
        
        verificationView.isHidden = false
        
        let preferences = UserDefaults.standard
        let signUpData: [String: Any] = ["name": (firstNameTxt.text! + " " + lastNameTxt.text!) ?? "Dyllan Test", "phoneNumber": mobileTxt.text ?? "81332572", "password": passwordTxt.text ?? "HAHAHAHA"]
        
        let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/user"
        
        Alamofire.request(url, method: .post, parameters: signUpData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                UIView.animate(withDuration: 5, animations: {
                    self.verificationView.alpha = 0
                }) { (finished) in
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
