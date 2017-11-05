//
//  BankDetailVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 22/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BankDetailVC: UIViewController {

    @IBOutlet weak var bankOwner: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var bankBranch: UITextField!
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var bankAccountTypeView: UIView!
    @IBOutlet weak var bankSelectedAccount: UILabel!
    @IBOutlet weak var bankAccountDropDown: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var bankDetailID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bankAccount.keyboardType = .numberPad
        bankAccountDropDown.isHidden = true
        errorLabel.isHidden = true
        
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewBtnTapped(tapGestureRecognizer:)))
        bankAccountTypeView.addGestureRecognizer(viewTapGestureRecognizer)
        
        checkForExistingBankDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForExistingBankDetails() {
        let url = SharritURL.devURL + "bank/user/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                if let data = response.result.value {
                    if JSON(data)["content"]["bankInformation"] != nil {
                        let bankDetails = JSON(data)["content"]["bankInformation"]
                        self.bankOwner.text = bankDetails["ownerName"].description
                        self.bankName.text = bankDetails["bankName"].description
                        self.bankBranch.text = bankDetails["bankBranch"].description
                        self.bankAccount.text = bankDetails["accountNumber"].description
                        
                        bankDetails["accountType"].int! == 0 ? (self.bankSelectedAccount.text = "Saving Account") : (self.bankSelectedAccount.text = "Current Account")
                        
                        self.bankDetailID = bankDetails["bankInformationId"].int!
                    }
                }
                break
            case .failure(_):
                print("Retrieve Bank Details API failed")
                break
            }
        }
    }
    
    func viewBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        bankAccountDropDown.isHidden = !bankAccountDropDown.isHidden
    }
    
    @IBAction func bankAccountBtnPressed(_ sender: UIButton) {
        bankSelectedAccount.text = sender.titleLabel?.text
        bankAccountDropDown.isHidden = true
    }
    
    @IBAction func proceedBtnPressed(_ sender: SharritButton) {
        if (bankOwner.text?.isEmpty)! || (bankName.text?.isEmpty)! || (bankBranch.text?.isEmpty)! || (bankAccount.text?.isEmpty)! {
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
            
            var accountType: Int
            bankSelectedAccount.text! == "Saving Account" ? (accountType = 0) : (accountType = 1)
            
            let bankData: [String: Any] = ["ownerName": bankOwner.text!, "bankName": bankName.text!, "bankBranch": bankBranch.text!, "accountNumber": bankAccount.text!, "accountType": accountType]
            
            var url: String!
            var methodType: HTTPMethod!
            
            if bankDetailID == -1 {
                url = SharritURL.devURL + "bank/user/" + String(describing: appDelegate.user!.userID)
                methodType = .post
            } else {
                url = SharritURL.devURL + "bank/" + String(describing: bankDetailID)
                methodType = .put
            }
            
            Alamofire.request(url, method: methodType, parameters: bankData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    self.navigationController?.popViewController(animated: true)
                    break
                case .failure(_):
                    print("Save/Edit Bank Details API failed")
                    break
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
