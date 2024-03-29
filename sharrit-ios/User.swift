//
//  User.swift
//  sharrit-ios
//
//  Created by Boon Jun on 15/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

enum Role {
    case Sharrie
    case Sharror
}

class User {
    var userID: Int
    var firstName: String
    var lastName: String
    var password: String
    var mobile: String
    var profilePhoto: String
    var accessToken: String
    var createDate: String
    var joinedSBList: [Int]
    var pendingSBList: [Int]
    var bankOwnerName: String?
    var bankName: String?
    var bankBranch: String?
    var bankAccount: String?
    var bankType: Int?
    var address: String?
    
    var email: String?
    var gender: String?
    var age: Int?
    
    init(userID: Int, firstName: String, lastName: String, password: String, mobile: String, profilePhoto: String, accessToken: String, createDate: String, joinedSBList: [Int], pendingSBList: [Int]) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.mobile = mobile
        self.profilePhoto = profilePhoto
        self.accessToken = accessToken
        self.createDate = createDate
        self.joinedSBList = joinedSBList
        self.pendingSBList = pendingSBList
    }
    
}
