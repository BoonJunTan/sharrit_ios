//
//  ProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewSection = ["", "SETTINGS"]
    let tableViewIcons = [[#imageLiteral(resourceName: "Sharrit_Logo"), #imageLiteral(resourceName: "reputation")], [#imageLiteral(resourceName: "profile2"), #imageLiteral(resourceName: "help"), #imageLiteral(resourceName: "change_role"), #imageLiteral(resourceName: "logout")]]
    let tableViewItems = [["My Sharres", "Reputation"], ["Profile Settings", "Help Centre", "View as Sharror", "Logout"]]

    @IBOutlet weak var starRating: CosmosView!
    let fakeRatingDouble = 4.7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        starRating.rating = fakeRatingDouble
        starRating.settings.fillMode = .precise
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight:CGFloat = tableViewSection[section].isEmpty ? 0.0 : 50.0
        return headerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell
        cell.iconLabel.text = tableViewItems[indexPath.section][indexPath.row]
        cell.iconImage.image = tableViewIcons[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: SharritButton) {
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        
        let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        loginVC.modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
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
    
}
