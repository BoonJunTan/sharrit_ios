//
//  SharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class SharesInfoVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
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
    
    @IBAction func chatWithSB(_ sender: SharritButton) {
        
    }
    
    @IBAction func sharrorBtnTapped(_ sender: SharritButton) {
        
    }
    
    
    
}
