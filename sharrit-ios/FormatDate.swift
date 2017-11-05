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
    
    func compareDaysCreatedInMinute(dateCreated: String) -> String {
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
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .full
        return formatter.string(from: endDate!, to: todayDate!)!
    }
    
    func compareTwoDaysInMinute(dateStart: String, dateEnd: String) -> String {
        let dateFormatter = DateFormatter()
        if dateStart.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        
        let startDate = dateFormatter.date(from: dateStart)
        
        if dateEnd.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        
        let endDate = dateFormatter.date(from: dateEnd)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .full
        return formatter.string(from: startDate!, to: endDate!)!
    }
    
    func compareTwoDays(dateStart: String, dateEnd: String) -> String {
        let dateFormatter = DateFormatter()
        if dateStart.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        
        let startDate = dateFormatter.date(from: dateStart)
        
        if dateEnd.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        
        let endDate = dateFormatter.date(from: dateEnd)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .full
        return formatter.string(from: startDate!, to: endDate!)!
    }
    
    func formatDateTimeToLocal(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: date + " 08:00:00")!
    }
    
    func formatDateTimeToLocal2(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: date)!
    }
    
    func formatDateTimeToLocal3(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        let dateGiven = dateFormatter.date(from: date)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd-MM-yyyy HH:mm"
        
        return dateFormatter2.string(from: dateGiven!)
    }
    
    func formatDateStringForDayAppointment(dateStart: String, dateEnd: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateStart = dateFormatter.date(from: dateStart)
        let dateEnd = dateFormatter.date(from: dateEnd)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd-MM-yyyy"
        
        return (dateFormatter2.string(from: dateStart!) + " to " + dateFormatter2.string(from: dateEnd!))
    }
    
    func formatDateStringForMinuteAppointment(dateStart: String, dateEnd: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateStart = dateFormatter.date(from: dateStart)
        let dateEnd = dateFormatter.date(from: dateEnd)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd-MM-yyyy"
        
        let dateFormatter3 = DateFormatter()
        dateFormatter3.dateFormat = "HH:mm"
        
        return (dateFormatter2.string(from: dateStart!) + " - " + dateFormatter3.string(from: dateStart!) + " to " + dateFormatter3.string(from: dateEnd!))
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
