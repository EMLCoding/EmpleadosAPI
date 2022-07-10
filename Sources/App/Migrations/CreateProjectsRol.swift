//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 10/7/22.
//

import Vapor
import Fluent

struct CreateProjectsRol: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ProjectRoles.schema)
            .id()
            .field(.name, .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(ProjectRoles.schema)
            .delete()
    }
}
