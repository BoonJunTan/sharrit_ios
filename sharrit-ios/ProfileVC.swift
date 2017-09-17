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
    var tableViewIcons:[[UIImage]]!
    var tableViewItems:[[String]]!

    @IBOutlet weak var profileLabe: UILabel!
    @IBOutlet weak var starRating: CosmosView!
    let fakeRatingDouble = 4.7
    @IBOutlet weak var profileDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        starRating.rating = fakeRatingDouble
        starRating.settings.fillMode = .precise
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        profileLabe.text = (appDelegate.user?.firstName)! + " " + (appDelegate.user?.lastName)!
        
        // Get user profile creation date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: (appDelegate.user?.createDate)!)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        profileDate.text = formatter.string(from: endDate!, to: todayDate!)
        
        setupProfileBtn()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupProfileBtn() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (appDelegate.user?.role == .Sharrie) {
            tableViewIcons = [[#imageLiteral(resourceName: "Sharrit_Logo"),#imageLiteral(resourceName: "reputation")], [#imageLiteral(resourceName: "profile2"), #imageLiteral(resourceName: "help"), #imageLiteral(resourceName: "change_role"), #imageLiteral(resourceName: "logout")]]
            tableViewItems = [["My Sharres", "Reputation"], ["Profile Settings", "Help Centre", "Switch to Sharror", "Logout"]]
        } else {
            tableViewIcons = [[#imageLiteral(resourceName: "Sharrit_Logo"), #imageLiteral(resourceName: "business"),#imageLiteral(resourceName: "reputation")], [#imageLiteral(resourceName: "profile2"), #imageLiteral(resourceName: "help"), #imageLiteral(resourceName: "change_role"), #imageLiteral(resourceName: "logout")]]
            tableViewItems = [["My Sharres", "Sharing Business", "Reputation"], ["Profile Settings", "Help Centre", "Switch to Sharrie", "Logout"]]
        }
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
        switch tableViewItems[indexPath.section][indexPath.row] {
        case "My Sharres":
            break
        case "Sharing Business":
            break
        case "Profile Settings":
            self.performSegue(withIdentifier: "editProfile", sender: self)
            break
        case "Switch to Sharror":
            tableViewItems[indexPath.section][indexPath.row] = "Switch to Sharrie"
            switchRole(newRole: .Sharror)
            break
        case "Switch to Sharrie":
            tableViewItems[indexPath.section][indexPath.row] = "Switch to Sharror"
            switchRole(newRole: .Sharrie)
            break
        case "Logout":
            logoutPressed()
            break
        default:
            break
        }
        tableView.reloadData()
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
    
    func switchRole(newRole: Role) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.user?.role = newRole
        navigationController?.navigationBar.barTintColor = NavBarUI().getNavBar()
        setupProfileBtn()
        tableView.reloadData()
    }
    
    func logoutPressed() {
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        
        let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        loginVC.modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
}
