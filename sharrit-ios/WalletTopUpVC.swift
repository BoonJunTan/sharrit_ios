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
    var paymentTextField: STPPaymentCardTextField!
    @IBOutlet weak var payButton: UIButton!
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

        topUpAmount.keyboardType = .numberPad
        let frame1 = CGRect(x: 20, y: 150, width: self.view.frame.size.width - 40, height: 40)
        paymentTextField = STPPaymentCardTextField(frame: frame1)
        paymentTextField.center = view.center
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        //disable payButton if there is no card information
        payButton.isEnabled = false
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
        let card = paymentTextField.cardParams
        //send card information to stripe to get back a token
        getStripeToken(card: card)
    }
    
    func getStripeToken(card:STPCardParams) {
        // get stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                print(token)
                self.postStripeToken(token: token)
            } else {
                print(error ?? "")
                
            }
        }
    }
    
    func postStripeToken(token: STPToken) {
        //Set up these params as your backend require
        var amount: String = topUpAmount.text!
        amount = amount.replacingOccurrences(of: ".", with: "")
        let params: [String: Any] = ["token": token.tokenId,
                                     "amount": Int(amount) ?? 0 ]
        print(params)
        let url = SharritURL.devURL + "wallet/charge/" + String(describing: appDelegate.user!.userID)
        print(url)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
                case .success(_):
                     if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == 1 {
                                // go to cheers page here
                            }
                        }
                    }
                    break
                case .failure(_):
                    print("error")
                    break
            }
        }
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid{
            payButton.isEnabled = true
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransaction" {
            if let topUpTransactionVC = segue.destination as? TopUpTransactionVC {
                topUpTransactionVC.walletManagement = walletManagement
            }
        }
    }
    
}
