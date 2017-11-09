//
//  SuccessfulBookingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 5/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation
import SwiftyJSON

class SuccessfulBookingVC: UIViewController {
    
    // Pass Over Data
    var receiverID: Int!
    var receiverName: String!
    var receiverType: Int!
    var sharreTitle: String!
    var sharreID: Int!
    var sharreDescription: String!
    var sharreImageURL: String!
    var collaborationList: [JSON]?
    var viewSharreFrom: ViewSharreFrom = .SharingBusiness
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.collaborationList != nil {
                self.performSegue(withIdentifier: "showCollaboration", sender: nil)
            } else {
                if self.viewSharreFrom == .SharingBusiness {
                    if self.collaborationList == nil {
                        let messageSB = UIStoryboard(name: "Messages" , bundle: nil)
                        let conversationVC = messageSB.instantiateViewController(withIdentifier: "conversation") as! ConversationVC
                        let messageWithNavController = UINavigationController(rootViewController: conversationVC)
                        
                        conversationVC.comingFrom = .Sharre
                        conversationVC.senderDisplayName = self.receiverName
                        conversationVC.receiverID = self.receiverID
                        conversationVC.receiverType = self.receiverType
                        let chat = Conversation(conversationPartner: self.receiverName, subjectTitle: self.sharreTitle)
                        chat.sharreID = self.sharreID
                        chat.sharreTitle = self.sharreTitle
                        chat.sharreImageURL = self.sharreImageURL
                        chat.sharreDescription = self.sharreDescription
                        conversationVC.chat = chat
                        
                        messageWithNavController.modalTransitionStyle = .coverVertical
                        self.modalPresentationStyle = .fullScreen
                        self.present(messageWithNavController, animated: true, completion:{
                            if let subviewsCount = self.tabBarController?.view.subviews.count {
                                if subviewsCount > 2 {
                                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                                }
                            }
                        })
                    }
                } else {
                    self.performSegue(withIdentifier: "showSharresTransaction", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConversation" {
            if let chatVC = segue.destination as? ConversationVC {
                chatVC.comingFrom = .Sharre
                chatVC.senderDisplayName = receiverName
                chatVC.receiverID = receiverID
                chatVC.receiverType = receiverType
                let chat = Conversation(conversationPartner: receiverName, subjectTitle: sharreTitle)
                chat.sharreID = sharreID
                chat.sharreTitle = sharreTitle
                chat.sharreImageURL = sharreImageURL
                chat.sharreDescription = sharreDescription
                chatVC.chat = chat
            }
        } else if segue.identifier == "showCollaboration" {
            if let collaborationVC = segue.destination as? CollaborationVC {
                collaborationVC.collaborationList = collaborationList
                collaborationVC.receiverID = receiverID
                collaborationVC.receiverName = receiverName
                collaborationVC.receiverType = receiverType
                collaborationVC.sharreTitle = sharreTitle
                collaborationVC.sharreID = sharreID
                collaborationVC.sharreDescription = sharreDescription
                collaborationVC.sharreImageURL = sharreImageURL
                collaborationVC.viewSharreFrom = viewSharreFrom
            }
        } else if segue.identifier == "showSharresTransaction" {
            if let showSharesInfoVC = segue.destination as? ShowSharesInfoVC {
                showSharesInfoVC.userRole = .Sharrie
                showSharesInfoVC.titleString = "Sharres Status OvervieW"
            }
        }
    }
}
