//
//  NotificationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NotificationVC: UITableViewController {
    
    var notificationList: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        navigationItem.rightBarButtonItem = navBarBubble
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllNotification()
        
        readAllNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell

        cell.notificationDetails.text = notificationList[indexPath.item].message
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let notificationDate = dateFormatter2.date(from: notificationList[indexPath.item].date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        cell.notificationDate.text = dateFormatter.string(from: notificationDate!)
        
        if !notificationList[indexPath.item].isRead {
            cell.backgroundColor = Colours.Gray.superLightGray
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    func getAllNotification() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let url = SharritURL.devURL + "notification/user/" + String(describing: appDelegate.user!.userID)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.notificationList = []
                    for (_, subJson) in JSON(data) {
                        self.notificationList.append(Notification(id: subJson["notificationId"].int!, type: subJson["type"].int!, typeId: subJson["typeId"].int!, date: subJson["dateCreated"].string!, message: subJson["message"].string!, isRead: subJson["isRead"].bool!))
                    }
                }
                self.tableView.reloadData()
                break
            case .failure(_):
                print("Get All Notification API failed")
                break
            }
        }
    }
    
    func readAllNotification() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let url = SharritURL.devURL + "notification/clear/" + String(describing: appDelegate.user!.userID)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let tabController = appDelegate.window?.rootViewController as? UITabBarController {
                    let tabItem = tabController.tabBar.items![2]
                    tabItem.badgeValue = nil
                }
                self.tableView.reloadData()
                break
            case .failure(_):
                print("Read Notification API failed")
                break
            }
        }
    }
}
