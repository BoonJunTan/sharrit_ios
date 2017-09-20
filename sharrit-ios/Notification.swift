//
//  Notification.swift
//  sharrit-ios
//
//  Created by Boon Jun on 21/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit

class Notification {
    let id: Int!
    let type: Int!
    let typeId: Int!
    let date: String!
    let message: String!
    
    init(id: Int, type: Int, typeId: Int, date: String, message: String) {
        self.id = id
        self.type = type
        self.typeId = typeId
        self.date = date
        self.message = message
    }
    
}
