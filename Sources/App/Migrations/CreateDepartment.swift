//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor
import Fluent

struct CreateDepartment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Departments.schema)
            .field(.id, .int, .identifier(auto: true)) // Como no se ha utilizado UUID para el ID en Departments, hay que utilizar el identificador como campo field y estableciendo el '.identifier(auto: true)' para que vaya creando el id automáticamente de manera incremental
            .field(.name, .string, .required)
            .unique(on: .name)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Departments.schema)
            .delete()
    }
}
