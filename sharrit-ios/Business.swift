//
//  Business.swift
//  
//
//  Created by Boon Jun on 20/9/17.
//
//

import Foundation
import SwiftyJSON

class Business {
    
    var businessId: Int!
    var businessName: String!
    var description: String?
    var businessType: Int?
    var dateCreated: String
    var logoURL: String
    var bannerURL: String
    var requestFormID: Int?
    var commissionRate: Double?
    var rating: Double!
    var ratingList: [JSON]?
    var collaborationList: [JSON]?
    var collaborationFromBanner: String?
    var categoryID: Int?
    var categoryName: String?
    
    init(businessId: Int, businessName: String, description: String, businessType: Int, logoURL: String, bannerURL: String, commissionRate: Double, dateCreated: String) {
        self.businessId = businessId
        self.businessName = businessName
        self.description = description
        self.businessType = businessType
        self.logoURL = logoURL
        self.bannerURL = bannerURL
        self.commissionRate = commissionRate
        self.dateCreated = dateCreated
    }
    
    init(businessId: Int, businessName: String, logoURL: String, bannerURL: String, dateCreated: String) {
        self.businessId = businessId
        self.businessName = businessName
        self.logoURL = logoURL
        self.bannerURL = bannerURL
        self.dateCreated = dateCreated
    }
}
