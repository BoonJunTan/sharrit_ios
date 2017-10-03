//
//  WalletTopUp.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Stripe

enum WalletManagement {
    case TopUp
    case CashOut
}

class WalletTopUpVC: UIViewController, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var topUpAmount: UITextField!
    
    @IBOutlet weak var creditCardView: UIView!
    var paymentTextField: STPPaymentCardTextField!
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var walletManagement: WalletManagement = .TopUp {
        didSet {
            switch walletManagement {
            case .TopUp:
                title = "Wallet Top Up"
                break
            case .CashOut:
                title = "Wallet Cash Out"
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topUpAmount.keyboardType = .decimalPad
        
        paymentTextField = STPPaymentCardTextField(frame: CGRect(x: 0, y: 0, width: creditCardView.frame.size.width, height: creditCardView.frame.size.height))
        paymentTextField.delegate = self
        creditCardView.addSubview(paymentTextField)
        
        errorLabel.isHidden = true
        payButton.isEnabled = false
        payButton.backgroundColor = UIColor.lightGray
        
        switch walletManagement {
        case .TopUp:
            payButton.setTitle("Proceed to Top Up", for: .normal)
            break
        case .CashOut:
            payButton.setTitle("Proceed to Cash Out", for: .normal)
            break
        }
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
        if (topUpAmount.text?.isEmpty)! {
            errorLabel.text = "Please enter an amount"
            errorLabel.isHidden = false
        } else {
            let card = paymentTextField.cardParams
            //send card information to stripe to get back a token
            getStripeToken(card: card)
        }
    }
    
    func getStripeToken(card:STPCardParams) {
        // get stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                self.postStripeToken(token: token)
            }
        }
    }
    
    func postStripeToken(token: STPToken) {
        //Set up these params as your backend require
        var amount: String = topUpAmount.text!
        if amount.contains(".") {
            amount = amount.replacingOccurrences(of: ".", with: "")
        } else {
            amount = amount + "00"
        }
        
        let params: [String: Any] = ["token": token.tokenId,
                                     "amount": Int(amount) ?? 0 ]
        
        let url = SharritURL.devURL + "wallet/charge/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                case .success(_):
                     if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == 1 {
                                self.performSegue(withIdentifier: "goToTransaction", sender: nil)
                            }
                        }
                    }
                    break
                case .failure(_):
                    print("Update Wallet API failure")
                    self.errorLabel.text = "Please enter valid credit card details"
                    self.errorLabel.isHidden = false
                    break
            }
        }
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid {
            payButton.isEnabled = true
            payButton.backgroundColor = Colours.Blue.sharritBlue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransaction" {
            if let topUpTransactionVC = segue.destination as? TopUpTransactionVC {
                topUpTransactionVC.walletManagement = walletManagement
                topUpTransactionVC.amount = topUpAmount.text!
            }
        }
    }
    
}
