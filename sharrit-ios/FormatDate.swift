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
    
    func generateTimeHrMin(rangeStart: String, rangeEnd:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let startTime = dateFormatter.date(from: rangeStart)
        let endTime = dateFormatter.date(from: rangeEnd)
        
        let calendar = Calendar.current
        let startTimeFormat = calendar.dateComponents([.hour, .minute], from: startTime!)
        let endTimeFormat = calendar.dateComponents([.hour, .minute], from: endTime!)
        
        let startTimeString = String(format: "%0.2d:%0.2d", startTimeFormat.hour!, startTimeFormat.minute!)
        let endTimeString = String(format: "%0.2d:%0.2d", endTimeFormat.hour!, endTimeFormat.minute!)
        
        return startTimeString + " - " + endTimeString
    }
}
