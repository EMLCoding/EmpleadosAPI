//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent
import SQLKit

struct Context: Decodable {
    let rows: [Empleados]
}

struct PruebasController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("parametros", "**", use: getAPIComodin)
        routes.get("sqlQuery", use: sqlQuery)
        routes.get("sqlQueryFilter", use: sqlQueryFilter)
        
        let empleado = routes.grouped("empleado")
        empleado.get("getEmpleado", ":id", use: getEmpleadoClient)
    }
    
    // Con los ** de la url del get recoge todos los parametros enviados por la url
    func getAPIComodin(req:Request) throws -> String {
        let name = req.parameters.getCatchall().joined(separator: ",") // Guarda en un array todos los parametros recibidos separados por ','
        return "Parámetros: \(name)"
    }
    
    // Ejemplo de una funcion que hace una peticion a otra API
    func getEmpleadoClient(req:Request) async throws -> Empleados {
        guard let id = req.parameters.get("id", as: Int.self) else { throw Abort(.badRequest) }
        let client = try await req.client.get("https://acemployeestest.herokuapp.com/api/getEmpleado/\(id)")
        return try client.content.decode(Empleados.self)
    }
    
    func sqlQuery(req:Request) async throws -> [Empleados] {
        return try await (req.db as! SQLDatabase).raw("SELECT * FROM empleados WHERE username = 'pepito'").all(decoding: Empleados.self).compactMap { results in
            return results
        }
    }
    
    func sqlQueryFilter(req:Request) async throws -> [Empleados] {
        try await Empleados.query(on: req.db)
            .filter(.sql(raw: "first_name = 'Edu'")) // Aqui se pone lo que iria despues del WHERE en SQL
            .all()
    }
}
