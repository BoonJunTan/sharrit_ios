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
    
    @IBOutlet weak var unitsAvailable: UILabel!
    @IBOutlet weak var unitsRequire: UITextField!
    
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var usageLabel: UILabel!
    
    @IBOutlet weak var costView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = sharreTitle
        depositLabel.text = sharreDeposit
        usageLabel.text = sharreUsageFee
        
        getAvailableUnit()
        
        unitsRequire.keyboardType = .numberPad
        unitsRequire.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        costView.isHidden = true
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
                    let alert = UIAlertController(title: "Error Occured!", message: "Not enough items at the moment!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    costView.isHidden = false
                }
            }
        } else {
            costView.isHidden = true
        }
    }
    
    func getAvailableUnit() {
        self.unitsAvailable.text = sharreUnit
        
        let url = SharritURL.devURL + "sharre/avail/time/" + String(describing: sharreID!)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        self.unitsAvailable.text = subJson["qty"].description
                    }
                }
                break
            case .failure(_):
                print("Get Available Unit Info API failed")
                break
            }
        }
    }
    
    @IBAction func bookBtnPressed(_ sender: SharritButton) {
        let deposit = depositLabel.text!.replacingOccurrences(of: "Deposit: $", with: "")
        
        let url = SharritURL.devURL + "transaction/" + String(describing: sharreID!)
        
        let filterData: [String: Any] = ["payerId": appDelegate.user!.userID, "payerType": 0, "amount": 0, "deposit": deposit, "qty": unitsRequire.text!]
        
        Alamofire.request(url, method: .post, parameters: filterData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
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
            }
        }
    }

}
