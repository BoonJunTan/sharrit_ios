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
    var tableViewItems:[Shares] = []
    
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
        
        print(url)
        
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
