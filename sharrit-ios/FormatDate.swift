//
//  DateFormatter.swift
//  sharrit-ios
//
//  Created by Boon Jun on 1/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

struct FormatDate {
    func compareDaysCreated(dateCreated: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: dateCreated)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        return formatter.string(from: endDate!, to: todayDate!)!
    }
}
