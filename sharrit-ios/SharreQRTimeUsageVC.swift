//
//  SharreQRTimeUsageVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 9/11/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharreQRTimeUsageVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Pass Over Data
    var sharreID: Int!
    var sharreTitle: String!
    var sharreDescription: String!
    var sharreImageURL: String?
    var sharreDeposit: String!
    var sharreUnit: String!
    var sharreUsageFee: String!
    var ownerName: String!
    var ownerID: Int!
    var ownerType: Int!
    var collaborationList: [JSON]?
    
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var usageLabel: UILabel!
    
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoAppliedLabel: UILabel!
    @IBOutlet weak var promoLabel: UITextField!
    
    @IBOutlet weak var costView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = sharreTitle
        depositLabel.text = sharreDeposit
        usageLabel.text = "Usage: 1 x " + sharreUsageFee
        
        promoAppliedLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getTotalCost() {
        let url = SharritURL.devURL + "transaction/pricing/" + String(describing: sharreID!)
        
        var totalCostRequest: [String: Any] = ["qty": 1, "timeStart": 0, "timeEnd": 0]
        
        if !(promoLabel.text?.isEmpty)! {
            totalCostRequest["promoCode"] = promoLabel.text!
        }
        
        Alamofire.request(url, method: .post, parameters: totalCostRequest, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    if JSON(data)["status"].int! == -1 {
                        self.promoAppliedLabel.isHidden = true
                        let alert = UIAlertController(title: "Error Occured!", message: "Promo Code is invalid", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        if !(self.promoLabel.text?.isEmpty)! {
                            self.promoAppliedLabel.isHidden = false
                        } else {
                            self.promoAppliedLabel.isHidden = true
                        }
                    }
                }
                break
            case .failure(_):
                print("Get Total Cost Info API failed")
                break
            }
        }
    }
    
    @IBAction func enterPromoBtnPressed(_ sender: SharritButton) {
        getTotalCost()
    }
    
    @IBAction func startBtnPressed(_ sender: SharritButton) {
        let deposit = depositLabel.text!.replacingOccurrences(of: "Deposit: $", with: "")
        
        let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/scan/qr/create/" + String(describing: sharreID!)
        
        var transactionData: [String: Any] = ["payerId": appDelegate.user!.userID, "deposit": deposit, "qty": 1, "api_key": "UAZPfHqf"]
        
        if !(promoLabel.text?.isEmpty)! {
            transactionData["promoCode"] = promoLabel.text!
        }
        
        Alamofire.request(url, method: .post, parameters: transactionData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    var json = JSON(data)
                    if json["status"] == 1 {
                        self.performSegue(withIdentifier: "viewSuccessful", sender: nil)
                    } else {
                        let alert = UIAlertController(title: "Error Occured!", message: "You do not have enough money in Wallet", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Wallet", style: .default, handler: { (_) in
                            self.tabBarController?.selectedIndex = 1
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                break
            case .failure(_):
                print("Transaction Submission API failed")
                break
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSuccessful" {
            if let successfulBookingVC = segue.destination as? SuccessfulBookingVC {
                successfulBookingVC.receiverName = ownerName
                successfulBookingVC.receiverID = ownerID
                successfulBookingVC.receiverType = ownerType
                successfulBookingVC.sharreTitle = sharreTitle
                successfulBookingVC.sharreID = sharreID
                successfulBookingVC.sharreDescription = sharreDescription
                successfulBookingVC.sharreImageURL = sharreImageURL
                successfulBookingVC.viewSharreFrom = .QRCode
                if collaborationList != nil {
                    successfulBookingVC.collaborationList = collaborationList
                }
            }
        }
    }
    
}
