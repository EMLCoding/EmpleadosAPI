//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor
import Fluent


struct CreateEmployees: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Employees.schema)
            .id()
            .field(.firstName, .string, .required)
            .field(.lastName, .string, .required)
            .field(.username, .string, .required)
            .field(.email, .string, .required)
            .field(.address, .string)
            .field(.zipcode, .string)
            .field(.avatar, .string, .required)
            .field(.department, .int, .references(Departments.schema, .id, onDelete: .setNull), .required) // Es de tipo int porque es el tipo de dato del ID de la tabla a la que tiene apuntando el FK. Además hace la creacion de la FK
            .unique(on: .email)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Employees.schema)
            .delete()
    }
}
