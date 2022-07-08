//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 8/7/22.
//

import Vapor

struct AddProjectsEmployees: Content {
    let projectID: UUID
    let employees: [UUID]
}
