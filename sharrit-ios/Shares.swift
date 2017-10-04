//
//  Shares.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

enum SharresType {
    case HrAppointment
    case DayAppointment
    case TimeUsage
}

class Shares {
    var sharreId: Int
    var name: String
    var description: String
    var type: Int
    var qty: Int
    var unit: Int
    var price: Double
    var deposit: Double
    var location: String
    var photos: [String]
    var dateCreated: String
    //var dateUpdated: String
    //var transactions: []
    var activeStart: String?
    var activeEnd: String?
    var ownerType: Int
    var ownerId: Int
    var isActive: Bool
    // var dateDeleted
    //var isDeleted:
    
    init(sharreId: Int, name: String, description: String, type: Int, qty: Int, unit: Int, price: Double, deposit: Double, location: String, photos: [String], dateCreated: String, ownerType: Int, ownerId: Int, isActive: Bool) {
        self.sharreId = sharreId
        self.name = name
        self.description = description
        self.type = type
        self.qty = qty
        self.unit = unit
        self.price = price
        self.deposit = deposit
        self.location = location
        self.photos = photos
        self.dateCreated = dateCreated
        self.ownerType = ownerType
        self.ownerId = ownerId
        self.isActive = isActive
    }
    
    func getSharresType() -> SharresType {
        if type == 0 {
            if unit == 0 {
                return .HrAppointment
            } else {
                return .DayAppointment
            }
        } else {
            return .TimeUsage
        }
    }
    
}
