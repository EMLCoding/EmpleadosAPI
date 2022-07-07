//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

// Es una clase necesaria para la relacion n:n de Employees y Projects
final class EmployeesProjects: Model {
    static let schema = "employees+projects"
    
    @ID(key: .id) var id: UUID?
    @Parent(key: .employeeID) var employee: Employees
    @Parent(key: .projectID) var project: Projects
}
