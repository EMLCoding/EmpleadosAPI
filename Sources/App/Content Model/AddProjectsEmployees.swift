//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 8/7/22.
//

import Vapor

struct EmployeeRol: Content {
    let idEmployee: UUID
    let idRol: UUID
}

struct AddProjectsEmployees: Content {
    let projectID: UUID
    let employees: [EmployeeRol]
}
