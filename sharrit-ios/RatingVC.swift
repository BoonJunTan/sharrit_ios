//
//  RatingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cosmos

class RatingVC: UIViewController {
    
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
        
        reviewTV.text = ""
        ratingView.settings.fillMode = .half
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        if ratingView.rating < 1 {
            let alert = UIAlertController(title: "Error", message: "Please give a rating of 1-5 stars", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if reviewTV.text == "" {
                let alert = UIAlertController(title: "Empty Review", message: "Continue to submit without leaving a review?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    self.submitRating(reviewAvailable: false)
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                submitRating(reviewAvailable: true)
            }
        }
    }
    
    func submitRating(reviewAvailable: Bool) {
        var url: String!
        
        // If Sharrie = Give Rating to Sharror
        if userRole == .Sharrie {
            url = SharritURL.devURL + "reputation/owner/" + String(describing: self.transaction.transactionId)
        } else {
            url = SharritURL.devURL + "reputation/user/" + String(describing: self.transaction.transactionId)
        }
        
        var ratingData = [String: Any]()
            
        if reviewAvailable {
            ratingData = ["ratingValue": ratingView.rating, "message": reviewTV.text!]
        } else {
            ratingData = ["ratingValue": ratingView.rating]
        }
        
        Alamofire.request(url!, method: .post, parameters: ratingData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(_):
                print("Give Rating API failed")
                break
            }
        }
    }
    
}
