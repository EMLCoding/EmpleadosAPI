//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent

struct PruebasController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("api", "**", use: getAPIComodin)
        
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
}
