//
//  Time.swift
//  sharrit-ios
//
//  Created by Boon Jun on 4/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

struct Time {
    func makeTimeInterval(startTime:String ,endTime:String) -> String {
        var arr = startTime.components(separatedBy: " ")[0].components(separatedBy: ":")
        let str = arr[1] as String
        
        if (Int(str)! > 0 && Int(str)! < 30) {
            arr[1] = "00"
        } else if(Int(str)! > 30) {
            arr[1] = "30"
        }
        
        let startT:String = "\(arr.joined(separator: ":"))  \(startTime.components(separatedBy: " ")[1])"
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm a"
        var fromTime:NSDate  = (timeFormat.date(from:startT) as NSDate?)!
        let toTime:NSDate  = (timeFormat.date(from:endTime) as NSDate?)!
        
        var dateByAddingThirtyMinute : NSDate!
        let timeinterval : TimeInterval = toTime.timeIntervalSince(fromTime as Date)
        let numberOfIntervals : Double = timeinterval / 3600;
        var formattedDateString : String!
        
        for _ in stride(from: 0, to: Int(numberOfIntervals * 2), by: 1) {
            dateByAddingThirtyMinute = fromTime.addingTimeInterval(1800)
            fromTime = dateByAddingThirtyMinute
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            formattedDateString = dateFormatter.string(from: dateByAddingThirtyMinute! as Date) as String?
            print("Time after 30 min = \(formattedDateString)")
        }
        
        return formattedDateString
    }
}
