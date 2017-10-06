//
//  WalletTransactionViewController.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WalletTransactionViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var transactionCollection: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTransaction()
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionCollection.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.transactionDate.text = FormatDate().compareDaysCreated(dateCreated: transactionCollection[indexPath.row].dateCreated) + " ago"
        
        let transactionType = transactionCollection[indexPath.row].getTransactionType()
        if transactionType == .Topup {
            cell.transactionTitle.text = "Account Top Up"
            cell.transactionImage.image = #imageLiteral(resourceName: "increase")
            cell.transactionDeposit.text = "Amount: $" + DecimalConverter().convertIntWithString(amount: String(describing: transactionCollection[indexPath.row].amount))
            cell.transactionUsage.isHidden = true
        } else if transactionType == .Cashout {
            cell.transactionTitle.text = "Account Cash Out"
            cell.transactionImage.image = #imageLiteral(resourceName: "decrease")
            cell.transactionDeposit.text = "Amount: $" + DecimalConverter().convertIntWithString(amount: String(describing: transactionCollection[indexPath.row].amount))
            cell.transactionUsage.isHidden = true
        } else if transactionType == .Refund {
            cell.transactionTitle.text = "Sharre Refund"
            cell.transactionImage.image = #imageLiteral(resourceName: "refund")
            cell.transactionDeposit.text = "Amount: $" + DecimalConverter().convertIntWithString(amount: String(describing: transactionCollection[indexPath.row].amount))
            cell.transactionUsage.isHidden = true
        } else {
            cell.transactionTitle.text = "Sharre Service"
            cell.transactionImage.image = #imageLiteral(resourceName: "service")
            cell.transactionDeposit.text = "Deposit: $" +  transactionCollection[indexPath.row].deposit
            cell.transactionUsage.text = "Usage: $" + transactionCollection[indexPath.row].amount
        }
        
        let transactionStatus = transactionCollection[indexPath.row].getTransactionStatus()
        cell.transactionStatus.layer.cornerRadius = 5
        cell.transactionStatus.layer.masksToBounds = true
        if transactionStatus == .Completed {
            cell.transactionStatus.text = "Completed"
        } else if transactionStatus == .Ongoing {
            cell.transactionStatus.text = "Ongoing"
        } else {
            cell.transactionStatus.text = "Refunded"
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewTransaction", sender: nil)
        // performSegue(withIdentifier: "viewTransaction", sender: business[indexPath.item])
    }
    
    func getTransaction() {
        let url = SharritURL.devURL + "user/history/all/" + String(describing: appDelegate.user!.userID)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.transactionCollection = []
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        let id = subJson["transactionId"].int!
                        let dateCreated = subJson["dateCreated"].description
                        let payeeId = subJson["payeeId"].int!
                        let payeeType = subJson["payeeType"].int!
                        let payerId = subJson["payerId"].int!
                        let payerType = subJson["payerType"].int!
                        let amount = subJson["amount"].description
                        let promoId = subJson["promoId"].int!
                        let timeStart = subJson["timeStart"].description
                        let timeEnd = subJson["timeEnd"].description
                        let status = subJson["status"].int!
                        let qty = subJson["qty"].int!
                        let deposit = subJson["deposit"].description
                        
                        let transaction = Transaction(transactionId: id, dateCreated: dateCreated, payeeId: payeeId, payeeType: payeeType, payerId: payerId, payerType: payerType, amount: amount, promoId: promoId, timeStart: timeStart, timeEnd: timeEnd, status: status, qty: qty, deposit: deposit)
                        
                        if let sharreId = subJson["sharreId"].int {
                            transaction.sharreId = sharreId
                        }
                        
                        self.transactionCollection.append(transaction)
                    }
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                print("Retrieve All Transaction for User API failed")
                break
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTransaction" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
            }
        }
    }

}
