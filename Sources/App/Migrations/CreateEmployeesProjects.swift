//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

struct CreateEmployeesProjects: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EmployeesProjects.schema)
            .id()
            .field(.employeeID, .uuid, .required, .references(Employees.schema, .id))
            .field(.projectID, .uuid, .required, .references(Projects.schema, .id))
            .unique(on: .employeeID, .projectID)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(EmployeesProjects.schema)
            .delete()
    }
}
