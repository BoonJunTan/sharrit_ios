//
//  Business.swift
//  
//
//  Created by Boon Jun on 20/9/17.
//
//

import Foundation

class Business {
    
    var businessId: Int!
    var businessName: String!
    var description: String!
    //var type: Int!
    //var tag: String?
    //var isVerified: Bool!
    //var isActive: Bool!
    var dateCreated: String
    //var dateUpdated: String
    //var category: String?
    //var categoryId: Int!
    
    init(businessId: Int, businessName: String, description: String, dateCreated: String) {
        self.businessId = businessId
        self.businessName = businessName
        self.description = description
        self.dateCreated = dateCreated
    }
}
