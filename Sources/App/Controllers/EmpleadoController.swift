//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent

struct EmpleadoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("getEmpleados", use: getEmpleados)
        routes.get("findEmpleado", ":empleado", use: findEmpleado)
        
        routes.group("empleado") { routesEmp in
            routesEmp.post(use: newEmpleado)
            routesEmp.group(":empleado") { emp in
                routes.get(use: getEmpleado)
                //emp.put(use: updateEmpleado)
                //emp.delete(use: deleteEmpleado)
            }
            
        }
    }
    
    func getEmpleados(req:Request) async throws -> [Empleados] {
        try await Empleados.query(on: req.db)
            .sort(\.$lastName) // Obtiene los empleados ordenados por el campo lastName
            .all() // Obtiene todos los empleados que haya en la tabla del modelo Empleados
    }
    
    func getEmpleado(req:Request) async throws -> Empleados {
        guard let empleadoID = req.parameters.get("empleado", as: UUID.self) else { throw Abort(.badRequest, reason: "El ID de empleado no es válido")}
        if let empleado = try await Empleados
            .query(on: req.db)
            .filter(\.$id == empleadoID) // Busca el registro cuyo campo id coincida con el valor exacto de empleadoID
            .first() {
            return empleado
        } else {
            throw Abort(.notFound, reason: "No existe un empleado con ese ID")
        }
    }
    
    // Funciona como el getEmpleado pero el ".find" solo vale para buscar por el campo ID de la tabla
    func findEmpleado(req:Request) async throws -> Empleados {
        if let empleado = try await Empleados.find(req.parameters.get("empleado", as: UUID.self), on: req.db) {
            return empleado
        } else {
            throw Abort(.notFound, reason: "El empleado no existe")
        }
    }
    
    func newEmpleado(req:Request) async throws -> Response {
        try Empleados.validate(content: req) // Hace las validaciones de la informacion recibida del front
        let empleado = try req.content.decode(Empleados.self)
        try await empleado.create(on: req.db)
        return Response(status: .created)
    }
    
//    func updateEmpleado(req:Request) async throws -> Response {}
//
//    func deleteEmpleado(req:Request) async throws -> Response {}
}
