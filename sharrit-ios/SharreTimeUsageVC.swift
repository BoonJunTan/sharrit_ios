//
//  SharreTimeUsageVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 29/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharreTimeUsageVC: UIViewController {

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
    
    @IBOutlet weak var unitsAvailable: UILabel!
    @IBOutlet weak var unitsRequire: UITextField!
    
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
        
        getAvailableUnit()
        
        unitsRequire.keyboardType = .numberPad
        unitsRequire.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        costView.isHidden = true
        promoView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            if let units = Int(unitsAvailable.text!), let unitsWanted = Int(textField.text!) {
                if units < unitsWanted {
                    costView.isHidden = true
                    promoView.isHidden = true
                    let alert = UIAlertController(title: "Error Occured!", message: "Not enough items at the moment!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if unitsWanted < 1 {
                    let alert = UIAlertController(title: "Error Occured!", message: "Item requested must be at least 1.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    getTotalCost()
                    usageLabel.text = "Usage: " + unitsRequire.text! + " x " + sharreUsageFee
                    costView.isHidden = false
                    promoView.isHidden = false
                }
            }
        } else {
            promoView.isHidden = true
            costView.isHidden = true
        }
    }
    
    func getAvailableUnit() {
        let url = SharritURL.devURL + "sharre/avail/time/" + String(describing: sharreID!)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        self.unitsAvailable.text = String(describing: (Int(self.sharreUnit)! - subJson["qty"].int!))
                    }
                }
                break
            case .failure(_):
                print("Get Available Unit Info API failed")
                break
            }
        }
    }
    
    func getTotalCost() {
        let url = SharritURL.devURL + "transaction/pricing/" + String(describing: sharreID!)
        
        var totalCostRequest: [String: Any] = ["qty": unitsRequire.text!, "timeStart": 0, "timeEnd": 0]
        
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
                        let alert = UIAlertController(title: "Error Occured!", message: "Promo Code don't exist", preferredStyle: .alert)
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
    
    @IBAction func bookBtnPressed(_ sender: SharritButton) {
        let deposit = depositLabel.text!.replacingOccurrences(of: "Deposit: $", with: "")
        
        let url = SharritURL.devURL + "transaction/" + String(describing: sharreID!)
        
        var transactionData: [String: Any] = ["payerId": appDelegate.user!.userID, "payerType": 0, "amount": 0, "deposit": deposit, "qty": unitsRequire.text!]
        
        if !(promoLabel.text?.isEmpty)! {
            transactionData["promo"] = promoLabel.text!
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
                if collaborationList != nil {
                    successfulBookingVC.collaborationList = collaborationList
                }
            }
        }
    }

}
