//
//  Message.swift
//  sharrit-ios
//
//  Created by Boon Jun on 14/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class Message {
    
    var id: String = ""
    var name: String = ""
    var latestMessage: String = ""
    
    init() {
        
    }
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
        self.latestMessage = ""
    }
    
    convenience init(id:String, name: String, members: [String], latestMessage: String) {
        self.init()
        self.id = id
        self.name = name
        self.latestMessage = latestMessage
    }
}
