//
//  TimeSlot.swift
//  sharrit-ios
//
//  Created by Boon Jun on 4/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

class TimeSlot {
    var timeStart: String
    var timeEnd: String
    var quantity: Int
    
    init(timeStart: String, timeEnd: String, quantity: Int) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.quantity = quantity
    }
}
