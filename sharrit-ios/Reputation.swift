//
//  Reputation.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class Reputation {
    var reputationID: Int!
    var userPhoto: String?
    var userName: String!
    var rating: Double!
    var review: String?
    var sharreName: String?
    var sharrePhoto: String?
    var sharreID: Int?
    
    init(reputationID: Int!, userName: String!, rating: Double!) {
        self.reputationID = reputationID
        self.userName = userName
        self.rating = rating
    }
}
