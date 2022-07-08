//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

// No se llega a utilizar esta carga pero sería asi como se hace una carga de datos desde un JSON guardado en el proyecto
struct LoadEmployees: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let employees = try getEmpleados()
        for emp in employees {
            if let dpto = try await database.query(Departments.self).filter(\.$name == emp.department).first() {
                try await Employees(firstName: emp.firstName, lastName: emp.lastName, username: emp.username, email: emp.email, address: emp.address, zipcode: emp.zipcode, avatar: emp.avatar, department: try dpto.requireID())
                    .create(on: database)
            }
        }
    }
    
    func revert(on database: Database) async throws {
        let employees = try getEmpleados().map(\.id)
        try await database.query(Employees.self)
            .filter(\.$id ~~ employees)
            .delete()
    }
    
    /// Se lee un archivo json con todos los empleados que se van a insertar en la BBDD
    func getEmpleados() throws -> [EmpleadoElement] {
        let working = DirectoryConfiguration.detect().workingDirectory
        let data = try Data(contentsOf: URL(fileURLWithPath: working).appendingPathComponent("EmpleadosData").appendingPathExtension("json"))
        return try JSONDecoder().decode([EmpleadoElement].self, from: data)
    }
}

struct EmpleadoElement: Codable {
    let id: UUID
    let username, firstName, lastName: String
    let email: String
    let department: String
    let address: String
    let avatar: String
    let zipcode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case firstName = "first_name"
        case lastName = "last_name"
        case email, department, address, avatar, zipcode
    }
}
