//
//  SharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharesInfoVC: UIViewController {
    
    var businessInfo: Business!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessStartDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        self.title = "Best Power Bank!"
        
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
        }
    }
    
}
