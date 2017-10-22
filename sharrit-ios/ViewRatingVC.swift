//
//  viewRatingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cosmos

class ViewRatingVC: UIViewController {
    
    // Pass over data
    var transaction: Transaction!
    var userRole: Role!
    
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var sharreTitleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var reviewTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        transactionIDLabel.text = String(describing: transaction.transactionId)
        sharreTitleLabel.text = transaction.sharreName
        
        ratingView.settings.fillMode = .half
        getRating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRating() {
        let url: String!
        
        if userRole == .Sharrie {
            // Get Specific Reputation given by Me (Sharrie)
            url = SharritURL.devURL + "reputation/user/" + String(describing: transaction.transactionId)
        } else {
            // Get Specific Reputation given by Me (Sharror)
            url = SharritURL.devURL + "reputation/owner/" + String(describing: transaction.transactionId)
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                // MUST TODO: WAITING FOR JOE
                if let data = response.result.value {
                    for (_, subJson) in JSON(data) {
                        
                    }
                }
                break
            case .failure(_):
                print("Get Specific Reputation API failed")
                break
            }
        }
    }
    
    @IBAction func deleteRating(_ sender: SharritButton) {
        let url: String!
        
        if userRole == .Sharrie {
            // Delete Specific Reputation given by Me (Sharrie)
            url = SharritURL.devURL + "reputation/user/" + String(describing: transaction.transactionId)
        } else {
            // Delete Specific Reputation given by Me (Sharror)
            url = SharritURL.devURL + "reputation/owner/" + String(describing: transaction.transactionId)
        }
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Delete Specific Reputation API failed")
                break
            }
        }
    }
    
}
