//
//  FormatNumber.swift
//  sharrit-ios
//
//  Created by Boon Jun on 11/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

struct FormatNumber {
    func giveTwoDP(number: NSNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: number)!
    }
}
