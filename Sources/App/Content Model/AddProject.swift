//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 8/7/22.
//

import Vapor

struct AddProject: Content {
    var name: String
    var desc: String
    var initDate: Date?
    var endDate: Date?
}

struct UpdateProject: Content {
    var name: String?
    var desc: String?
    var initDate: Date?
    var endDate: Date?
}
