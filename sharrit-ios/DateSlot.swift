//
//  DateSlot.swift
//  sharrit-ios
//
//  Created by Boon Jun on 5/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class DateSlot {
    var dateStart: String
    var quantity: Int
    
    init(dateStart: String, quantity: Int) {
        self.dateStart = dateStart
        self.quantity = quantity
    }
}
