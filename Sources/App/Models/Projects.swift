//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

final class Projects: Model, Content {
    static let schema = "projects"
    
    @ID(key: .id) var id: UUID?
    @Field(key: .name) var name: String
    @Field(key: .description) var desc: String
    @Field(key: .initDate) var initDate: Date?
    @Field(key: .endDate) var endDate: Date?
    @Siblings(through: EmployeesProjects.self, from: \.$project, to: \.$employee) var employees: [Employees]
}
