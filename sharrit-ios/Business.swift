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
    //var tag: String?
    //var isVerified: Bool!
    //var isActive: Bool!
    var dateCreated: String
    //var dateUpdated: String
    //var category: String?
    //var categoryId: Int!
    var logoURL: String
    var bannerURL: String
    var requestFormID: Int?
    var commissionRate: Double?
    var rating: Double!
    var ratingList: [JSON]?
    
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
