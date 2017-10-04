//
//  DecimalConverter.swift
//  sharrit-ios
//
//  Created by Boon Jun on 4/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

struct DecimalConverter {
    func convertIntWithString(amount: String) -> String {
        var currentAmount = amount
        if currentAmount.characters.count > 2 {
            currentAmount.insert(".", at: (currentAmount.index((currentAmount.endIndex), offsetBy: -2)))
        } else {
            currentAmount = "0." + currentAmount
        }
        return currentAmount
    }
}
