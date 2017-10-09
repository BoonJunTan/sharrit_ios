//
//  SuccessfulBookingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 5/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class SuccessfulBookingVC: UIViewController {
    
    // Pass Over Data
    var receiverID: Int!
    var receiverName: String!
    var receiverType: Int!
    var sharreTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            //self.navigationController?.popToRootViewController(animated: false)
            self.performSegue(withIdentifier: "showConversation", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConversation" {
            if let chatVC = segue.destination as? ConversationVC {
                chatVC.comingFrom = .Sharre
                chatVC.senderDisplayName = receiverName
                chatVC.receiverID = receiverID
                chatVC.receiverType = receiverType
                chatVC.chat = Conversation(conversationPartner: receiverName, subjectTitle: sharreTitle)
            }
        }
    }
}
