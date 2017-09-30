//
//  SharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharesInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Pass over value
    var businessInfo: Business!
    var categoryID: Int!
    var categoryName: String!
    
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessStartDate: UILabel!
    @IBOutlet weak var joinSharrorBtn: SharritButton!
    @IBOutlet weak var pendingApprovalBtn: SharritButton!
    @IBOutlet weak var createSharreBtn: SharritButton!
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewSection = ["Description", "Reviews"]
    var review:[String] = []
    var tableViewItems:[[String]] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        self.title = businessInfo.businessName
        
        businessName.text = businessInfo.businessName
        
        // Get user profile creation date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: businessInfo.dateCreated)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        businessStartDate.text = formatter.string(from: endDate!, to: todayDate!)

        createSharreBtn.isHidden = true
        joinSharrorBtn.isHidden = true
        pendingApprovalBtn.isHidden = true
        
        // First check - 3rd Party Business
        if businessInfo.businessType == 1 {
            // Second check - If User already joined business or pending
            if (appDelegate.user?.joinedSBList.contains(businessInfo.businessId))! {
                createSharreBtn.isHidden = false
            } else if (appDelegate.user?.pendingSBList.contains(businessInfo.businessId))! {
                pendingApprovalBtn.isHidden = false
            } else {
                // Third check - If there is a request form
                if businessInfo.requestFormID != -1 {
                    joinSharrorBtn.isHidden = false
                }
            }
        }
        
        tableViewItems.append([businessInfo.description!])
        
        // Setup some test data
        review.append("Review Test Data 1")
        review.append("Review Test Data 2")
        tableViewItems.append(review)
    }
    
    // Set up Table View - Description and Reviews
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as! DescriptionTableViewCell
            cell.descriptionLabel.text = businessInfo.description
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTableViewCell
            cell.profileImage.image = #imageLiteral(resourceName: "empty")
            cell.profileName.text = "Test Profile Name"
            cell.ratingLabel.text = review[indexPath.item]
            cell.ratingView.rating = 4.5
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
    // Go To Messages
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitForm" {
            if let sharrorFormVC = segue.destination as? SharrorFormVC {
                sharrorFormVC.companyName = businessInfo.businessName
                sharrorFormVC.companyId = businessInfo.businessId!
            }
        } else if segue.identifier == "contactBusiness" {
            if let contactBusinessVC = segue.destination as? ContactBusinessVC {
                contactBusinessVC.sharingBusinessName = businessInfo.businessName
                contactBusinessVC.sharingBusinessID = businessInfo.businessId
            }
        } else if segue.identifier == "createNewSharre" {
            if let newShareVC = segue.destination as? NewSharreVC {
                newShareVC.businessName = businessInfo.businessName
                newShareVC.businessID = businessInfo.businessId
                newShareVC.categoryID = categoryID
                newShareVC.categoryName = categoryName
            }
        }
    }
    
}
