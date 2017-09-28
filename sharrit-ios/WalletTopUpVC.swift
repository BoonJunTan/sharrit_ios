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
import MFCard

enum WalletManagement {
    case TopUp
    case CashOut
}

class WalletTopUpVC: UIViewController, MFCardDelegate {
    
    @IBOutlet weak var creditCardView: MFCardView!
    @IBOutlet weak var topUpAmount: UITextField!
    
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
        creditCardView.delegate = self
        creditCardView.autoDismiss = false
        creditCardView.toast = true
        
        topUpAmount.keyboardType = .numberPad
    }
    
    // MFCard Protocol Method
    func cardDoneButtonClicked(_ card: Card?, error: String?) {
        if error == nil {
            print(card!)
            performSegue(withIdentifier: "goToTransaction", sender: nil)
        } else {
            print(error!)
        }
    }
    
    func cardTypeDidIdentify(_ cardType: String) {
        print(cardType)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransaction" {
            if let topUpTransactionVC = segue.destination as? TopUpTransactionVC {
                topUpTransactionVC.walletManagement = walletManagement
            }
        }
    }
    
}
