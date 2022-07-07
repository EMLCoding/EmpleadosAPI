//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

struct CreateProjects: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Projects.schema)
            .id()
            .field(.name, .string, .required)
            .field(.description, .string, .required)
            .field(.initDate, .date)
            .field(.endDate, .date)
        // No hace falta añadir el campo de la relacion n:n con la tabla Employee
            .unique(on: .name)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Projects.schema)
            .delete()
    }
}
