//
//  WalletCashOutVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 22/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WalletCashOutVC: UIViewController {

    @IBOutlet weak var cashOutAmount: UITextField!
    @IBOutlet weak var bankOwnerName: UILabel!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankBranch: UILabel!
    @IBOutlet weak var bankAccountNumber: UILabel!
    @IBOutlet weak var bankAccountType: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var proceedBtn: SharritButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        errorLabel.isHidden = true
        cashOutAmount.keyboardType = .decimalPad
        
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
                        self.bankOwnerName.text = bankDetails["ownerName"].description
                        self.bankName.text = bankDetails["bankName"].description
                        self.bankBranch.text = bankDetails["bankBranch"].description
                        self.bankAccountNumber.text = bankDetails["accountNumber"].description
                        
                        bankDetails["accountType"].int! == 0 ? (self.bankAccountType.text = "Saving Account") : (self.bankAccountType.text = "Current Account")
                        
                        self.proceedBtn.isHidden = false
                    } else {
                        self.bankOwnerName.text = "Please fill up details @ Profile Page"
                        self.bankName.text = "Please fill up details @ Profile Page"
                        self.bankBranch.text = "Please fill up details @ Profile Page"
                        self.bankAccountNumber.text = "Please fill up details @ Profile Page"
                        self.bankAccountType.text = "Please fill up details @ Profile Page"
                        self.proceedBtn.isHidden = true
                    }
                }
                break
            case .failure(_):
                print("Retrieve Bank Details API failed")
                break
            }
        }
    }
    
    @IBAction func proceedBtnPressed(_ sender: SharritButton) {
        if (cashOutAmount.text?.isEmpty)! {
            errorLabel.isHidden = false
        } else {
            let cashOutData: [String: Any] = ["amount": String(format: "%.2f", Double(cashOutAmount.text!)!)]
            
            let url = SharritURL.devURL + "wallet/cashout/user/" + String(describing: appDelegate.user!.userID)
            
            Alamofire.request(url, method: .post, parameters: cashOutData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    self.navigationController?.popViewController(animated: true)
                    break
                case .failure(_):
                    print("Cash Out Details API failed")
                    break
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransaction" {
            if let topUpTransactionVC = segue.destination as? TopUpTransactionVC {
                topUpTransactionVC.walletManagement = .CashOut
                topUpTransactionVC.amount = cashOutAmount.text!
            }
        }
    }

}
