//
//  Message.swift
//  sharrit-ios
//
//  Created by Boon Jun on 14/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class Conversation {
    
    var id: Int?
    var conversationPartner: String!
    //var conversationPartnerImage: UIImage!
    var latestMessage: String?
    var subjectTitle: String?
    var lastestMessageDate: String?
    
    // For Sharres
    var sharreID: Int?
    var sharreTitle: String?
    var sharreDescription: String?
    var sharreImageURL: String?
    
    init(id: Int, conversationPartner: String, latestMessage: String, subjectTitle: String, lastestMessageDate: String) {
        self.id = id
        self.conversationPartner = conversationPartner
        self.latestMessage = latestMessage
        self.subjectTitle = subjectTitle
        self.lastestMessageDate = lastestMessageDate
    }
    
    init(conversationPartner: String, subjectTitle: String) {
        self.conversationPartner = conversationPartner
        self.subjectTitle = subjectTitle
    }
}
