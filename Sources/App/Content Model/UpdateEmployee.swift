//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 8/7/22.
//

import Vapor

struct UpdateEmployee: Content {
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var address: String?
    var zipcode: String?
    var avatar: String?
    var department: Int?
}

