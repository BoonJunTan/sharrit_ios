//
//  RegexCheck.swift
//  sharrit-ios
//
//  Created by Boon Jun on 21/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

struct RegexCheck {
    func checkGeneralPhone(phoneNumber: String) -> Bool {
        let GENERAL_PHONE = "^\\d{1,}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", GENERAL_PHONE)
        let result =  phoneTest.evaluate(with: phoneNumber)
        return result
    }
    
    func checkSGPhone(phoneNumber: String) -> Bool {
        let SG_PHONE = "^[8-9]\\d{7}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", SG_PHONE)
        let result =  phoneTest.evaluate(with: phoneNumber)
        return result
    }
    
    func checkMinPassword(password: String) -> Bool {
        let MIN_PASSWORD = "^.{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", MIN_PASSWORD)
        let result = passwordTest.evaluate(with: password)
        print(result)
        return result
    }
}
