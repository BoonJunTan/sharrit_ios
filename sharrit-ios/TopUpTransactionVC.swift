//
//  TopUpTransactionVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

// Use For Top Up/Withdraw
class TopUpTransactionVC: UIViewController {
    
    @IBOutlet weak var topUpAmount: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    
    var walletManagement: WalletManagement!
    var amount: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topUpAmount.text = "$" + amount
        
        if walletManagement == .TopUp {
            title = "Top Up Transactipn"
            transactionLabel.text = "Top Up Successfully. Cheers!"
        } else {
            title = "Cash Out Transaction"
            transactionLabel.text = "Cash Out Request Submitted. Please check transaction history for new update. Cheers!"
        }
        
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
}
