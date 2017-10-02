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

enum TransactionStatus {
    case Ongoing
    case Upcoming
    case History
}

class ShowSharesInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titleString: String!
    var userRole: Role!
    var transactionStatus: TransactionStatus!
    
    @IBOutlet weak var ongoingBtn: SharritButton!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var historyBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewItems:[Shares] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = titleString
        
        defaultBtnUI()
        currentBtnSelected(btn: ongoingBtn)
        transactionStatus = .Ongoing
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
        
        retrieveShares()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7 //tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharesInfoCell") as! SharesInfoTableViewCell
//        cell.sharesImage.image = tableViewItems[indexPath.row].
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "viewSharesInfo", sender: sharesCollection[indexPath.item])
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
        transactionStatus = .Ongoing
    }
    
    @IBAction func upcomingBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: upcomingBtn)
        transactionStatus = .Upcoming
    }
    
    @IBAction func historyBtnPressed(_ sender: Any) {
        defaultBtnUI()
        currentBtnSelected(btn: historyBtn)
        transactionStatus = .History
    }
    
    func retrieveShares() {
        var url = SharritURL.devURL + "user/history/"
        
        // MUST TODO: Check with Ronald on this
        if userRole == .Sharror || userRole == .Sharrie {
            if transactionStatus == .Ongoing {
                url = url + "ongoing/"
            } else if transactionStatus == .Upcoming {
                url = url + "upcoming/"
            } else {
                url = url + "completed/"
            }
            
            url = url + String(describing: appDelegate.user!.userID)
        } else {
            
        }
        
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
    
}
