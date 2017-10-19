//
//  ShowSharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum SharreStatus {
    case Ongoing
    case Upcoming
    case Completed
}

class ShowSharesInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titleString: String!
    var userRole: Role!
    var sharreStatus: SharreStatus!
    
    @IBOutlet weak var ongoingBtn: SharritButton!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var historyBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewItems:[Transaction] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = titleString
        
        defaultBtnUI()
        currentBtnSelected(btn: ongoingBtn)
        sharreStatus = .Ongoing
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveShares()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharesInfoCell") as! SharesInfoTableViewCell
        
        cell.sharesTitle.text = String(describing: tableViewItems[indexPath.row].transactionId) + ". " + String(describing: tableViewItems[indexPath.row].sharreName!)
        cell.sharesDeposit.text = "Deposit: $" + tableViewItems[indexPath.row].deposit
        cell.sharesUsage.text = "Usage: $" + tableViewItems[indexPath.row].amount
        
        if tableViewItems[indexPath.row].getSharreServiceType() == .TimeUsage {
            if tableViewItems[indexPath.row].hasStarted! {
                let timeString = FormatDate().compareDaysCreated2(dateCreated: tableViewItems[indexPath.row].timeStart)
                cell.sharesDate.text = "Duration: " + timeString
                var time = timeString.replacingOccurrences(of: " minutes", with: "")
                time = time.replacingOccurrences(of: ",", with: "")
                time = time.replacingOccurrences(of: " minute", with: "")
                if let onGoingPrice = tableViewItems[indexPath.row].sharreOnGoingPrice {
                    let calculatePrice = onGoingPrice / 60.0 * Double(time)!
                    cell.sharesUsage.text = "Usage: " + String(format: "%.2f", calculatePrice) + "+++"
                } else {
                    cell.sharesUsage.text = "Usage: " + tableViewItems[indexPath.row].amount
                }
            } else {
                cell.sharesDate.text = "Duration: Not Started Yet"
                cell.sharesUsage.text = "Usage: $0"
            }
        } else if tableViewItems[indexPath.row].getSharreServiceType() == .DayAppointment {
            cell.sharesDate.text = FormatDate().formatDateStringForDayAppointment(dateStart: tableViewItems[indexPath.row].timeStart, dateEnd: tableViewItems[indexPath.row].timeEnd)
        } else {
            cell.sharesDate.text = FormatDate().formatDateStringForMinuteAppointment(dateStart: tableViewItems[indexPath.row].timeStart, dateEnd: tableViewItems[indexPath.row].timeEnd)
        }
        
        cell.depositStatusView.isHidden = true
        cell.refundStatusView.isHidden = true
        
        if sharreStatus == .Completed {
            cell.sharesImage.image = #imageLiteral(resourceName: "completed")
            cell.depositStatusView.isHidden = false
            if let depositOnHold = tableViewItems[indexPath.row].isHoldingDeposit {
                if depositOnHold {
                    cell.depositStatusLabel.text = "On Hold"
                    cell.depositStatusView.backgroundColor = UIColor.orange
                } else {
                    cell.depositStatusLabel.text = "Returned"
                    cell.depositStatusView.backgroundColor = UIColor.green
                }
            }
            
            if let isWaitingRefund = tableViewItems[indexPath.row].isWaitingRefund {
                if isWaitingRefund {
                    cell.refundStatusView.isHidden = false
                    cell.refundStatusLabel.text = "Refunding"
                    cell.refundStatusView.backgroundColor = UIColor.orange
                }
            } else if tableViewItems[indexPath.row].getTransactionStatus() == .Refunded {
                cell.refundStatusView.isHidden = false
                cell.refundStatusLabel.text = "Refunded!"
                cell.refundStatusView.backgroundColor = UIColor.green
            } // Rejected
        } else if sharreStatus == .Ongoing {
            cell.sharesImage.image = #imageLiteral(resourceName: "on-going")
        } else {
            cell.sharesImage.image = #imageLiteral(resourceName: "upcoming")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewItems[indexPath.row].hasStarted != nil  && userRole == .Sharror {
            if sharreStatus == .Completed {
                let optionMenu = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    
                }
                
                let holdDepositAction = UIAlertAction(title: "Hold Deposit", style: .default) { action -> Void in
                    self.returnDepositForShares(boolean: false, transactionID: self.tableViewItems[indexPath.row].transactionId)
                }
                
                let returnDepositAction = UIAlertAction(title: "Return Deposit", style: .default) { action -> Void in
                    self.returnDepositForShares(boolean: true, transactionID: self.tableViewItems[indexPath.row].transactionId)
                }
                
                if tableViewItems[indexPath.row].isWaitingRefund! {
                    let viewRefundAction = UIAlertAction(title: "View Refund Details", style: .default) { action -> Void in
                        self.performSegue(withIdentifier: "viewRefund", sender: self.tableViewItems[indexPath.row])
                    }
                    optionMenu.addAction(viewRefundAction)
                }
                
                let reviewAction = UIAlertAction(title: "Review Sharres", style: .default) { action -> Void in
                    self.performSegue(withIdentifier: "viewRating", sender: self.tableViewItems[indexPath.row])
                }
                
                optionMenu.addAction(holdDepositAction)
                optionMenu.addAction(returnDepositAction)
                optionMenu.addAction(reviewAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
            } else {
                let optionMenu = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    
                }
                
                var nextActionTitle: String!
                tableViewItems[indexPath.row].hasStarted! ? (nextActionTitle = "End Sharre") : (nextActionTitle = "Start Sharre")
                
                let nextAction = UIAlertAction(title: nextActionTitle, style: .default) { action -> Void in
                    self.startEndShares(boolean: self.tableViewItems[indexPath.row].hasStarted!, transactionID: self.tableViewItems[indexPath.row].transactionId)
                }
                
                optionMenu.addAction(nextAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else if userRole == .Sharrie && sharreStatus == .Completed {
            let optionMenu = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                
            }
            
            if let isWaitingRefund = tableViewItems[indexPath.row].isWaitingRefund {
                if !isWaitingRefund {
                    let refundAction = UIAlertAction(title: "Request for Refund", style: .default) { action -> Void in
                        let sharresDetail: [String:Any] = ["TransactionID": self.tableViewItems[indexPath.row].transactionId, "SharreName": self.tableViewItems[indexPath.row].sharreName!]
                        self.performSegue(withIdentifier: "requestRefund", sender: sharresDetail)
                    }
                    optionMenu.addAction(refundAction)
                }
            }
            
            let reviewAction = UIAlertAction(title: "Review Sharres", style: .default) { action -> Void in
                self.performSegue(withIdentifier: "viewRating", sender: self.tableViewItems[indexPath.row])
            }
            
            optionMenu.addAction(reviewAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func startEndShares(boolean: Bool, transactionID: Int) {
        var url: String!
        
        if !boolean {
            url = SharritURL.devURL + "transaction/start/" + String(describing: transactionID)
        } else {
            url = SharritURL.devURL + "transaction/end/" + String(describing: transactionID)
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.retrieveShares()
                break
            case .failure(_):
                print("Start/End Service API failed")
                break
            }
        }
    }
    
    func returnDepositForShares(boolean: Bool, transactionID: Int) {
        var url: String!
        
        if boolean {
            url = SharritURL.devURL + "transaction/deposit/return/" + String(describing: transactionID)
        } else {
            url = SharritURL.devURL + "transaction/deposit/keep/" + String(describing: transactionID)
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.retrieveShares()
                break
            case .failure(_):
                print("Return/Hold Deposit API failed")
                break
            }
        }
    }
    
    func goToMessages() {
        let messageSB = UIStoryboard(name: "Messages" , bundle: nil)
        let messageVC = messageSB.instantiateViewController(withIdentifier: "messages") as! MessagesVC
        let messageWithNavController = UINavigationController(rootViewController: messageVC)
        
        messageWithNavController.modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        present(messageWithNavController, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
    func currentBtnSelected(btn: UIButton) {
        btn.backgroundColor = Colours.Blue.sharritBlue
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func defaultBtnUI() {
        ongoingBtn.backgroundColor = UIColor.white
        ongoingBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        upcomingBtn.backgroundColor = UIColor.white
        upcomingBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        historyBtn.backgroundColor = UIColor.white
        historyBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    @IBAction func ongoingBtnPressed(_ sender: SharritButton) {
        defaultBtnUI()
        currentBtnSelected(btn: ongoingBtn)
        sharreStatus = .Ongoing
        retrieveShares()
    }
    
    @IBAction func upcomingBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: upcomingBtn)
        sharreStatus = .Upcoming
        retrieveShares()
    }
    
    @IBAction func historyBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: historyBtn)
        sharreStatus = .Completed
        retrieveShares()
    }
    
    func retrieveShares() {
        var url = SharritURL.devURL
        
        if userRole == .Sharrie {
            url = url + "user/history/"
        } else {
            url = url + "sharror/history/"
        }
        
        if sharreStatus == .Ongoing {
            url = url + "ongoing/"
        } else if sharreStatus == .Upcoming {
            url = url + "upcoming/"
        } else {
            url = url + "completed/"
        }
        
        url = url + String(describing: appDelegate.user!.userID)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.tableViewItems = []
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
                        
                        if let sharreHasStarted = subJson["hasStarted"].bool {
                            transaction.hasStarted = sharreHasStarted
                        }
                        
                        if let isHoldingDeposit = subJson["isHoldingDeposit"].bool {
                            transaction.isHoldingDeposit = isHoldingDeposit
                        }
                        
                        if let isWaitingRefund = subJson["isWaitingRefund"].bool {
                            transaction.isWaitingRefund = isWaitingRefund
                        }

                        if let sharrePrice = subJson["price"].double {
                            transaction.sharreOnGoingPrice = sharrePrice
                        }
                        
                        if let sharreUnit = subJson["unit"].int {
                            transaction.sharreUnit = sharreUnit
                        }
                        
                        if let sharreType = subJson["type"].int {
                            transaction.sharreType = sharreType
                        }
                        
                        transaction.sharreName = subJson["name"].description
                        
                        self.tableViewItems.append(transaction)
                    }
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                print("Retrieve User Sharres Transaction API failed")
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestRefund" {
            if let requestRefundVC = segue.destination as? RequestRefundVC, let details = sender as? [String: Any] {
                requestRefundVC.transactionID = details["TransactionID"] as! Int
                requestRefundVC.sharreTitle = details["SharreName"] as! String
            }
        } else if segue.identifier == "viewRefund" {
            if let viewRefundVC = segue.destination as? ViewRefundVC {
                viewRefundVC.transaction = sender as! Transaction
            }
        } else if segue.identifier == "viewRating" {
            if let ratingVC = segue.destination as? RatingVC {
                ratingVC.transaction = sender as! Transaction
                ratingVC.userRole = userRole
            }
        }
    }
    
}
