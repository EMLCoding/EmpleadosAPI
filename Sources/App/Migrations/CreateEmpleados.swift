//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent

struct CreateEmpleados: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Empleados.schema)
            .id()// se pone id porque en Empleados se esta utilizando el ID por defecto de Vapor. Automaticamente lo pone como PK y autoincremental
            .field(.firstName, .string, .required)
            .field(.lastName, .string, .required)
            .field(.username, .string, .required)
            .field(.email, .string, .required)
            .field(.address, .string)
            .field(.zipcode, .string)
            .field(.avatar, .string, .required)
            .unique(on: .email) // Si se quieren varios campos unicos, se ponen separados por coma (on: .email, .username)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Empleados.schema)
            .delete()
    }
}
