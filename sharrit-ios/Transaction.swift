//
//  Transaction.swift
//  sharrit-ios
//
//  Created by Boon Jun on 3/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import Foundation

enum TransactionType {
    case Topup
    case Cashout
    case Refund
    case Service
}

enum TransactionStatus {
    case Ongoing
    case Completed
    case Refunded
}

class Transaction {
    
    var transactionId: Int
    var dateCreated: String
    //var dateUpdated: String
    var payeeId: Int
    var payeeType: Int
    var payerId: Int
    var payerType: Int
    var amount: String
    var promoId: Int
    var timeStart: String
    var timeEnd: String
    var status: Int
    //var sharre": null,
    var sharreId: Int?
    var qty: Int
    var deposit: String
    var sharreName: String?
    var hasStarted: Bool?
    var sharreOnGoingPrice: Double?
    var sharreType: Int?
    var sharreUnit: Int?
    var isHoldingDeposit: Bool?
    var isWaitingRefund: Bool?
    
    init(transactionId: Int, dateCreated: String, payeeId: Int, payeeType: Int, payerId: Int, payerType: Int, amount: String, promoId: Int, timeStart: String, timeEnd: String, status: Int, qty: Int, deposit: String) {
        self.transactionId = transactionId
        self.dateCreated = dateCreated
        self.payeeId = payeeId
        self.payeeType = payeeType
        self.payerId = payerId
        self.payerType = payerType
        self.amount = amount
        self.promoId = promoId
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.status = status
        self.qty = qty
        self.deposit = deposit
    }
    
    func getTransactionType() -> TransactionType {
        if payeeId == 0 && payeeType == 3 {
            return .Topup
        } else if payerId == 0 && payerType == 3 {
            return .Cashout
        } else if status == 2 {
            return .Refund
        } else {
            return .Service
        }
    }
    
    func getTransactionStatus() -> TransactionStatus {
        if status == 0 {
            return .Ongoing
        } else if status == 1 {
            return .Completed
        } else {
            return .Refunded
        }
    }
    
    func getSharreServiceType() -> SharresType {
        if sharreType == 1 {
            return .TimeUsage
        } else {
            if sharreUnit == 1 {
                return .DayAppointment
            } else {
                return .HrAppointment
            }
        }
    }
}
