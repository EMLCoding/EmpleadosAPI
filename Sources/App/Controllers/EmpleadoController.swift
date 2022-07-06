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
                emp.put(use: updateEmpleado)
                emp.delete(use: deleteEmpleado)
            }
            
        }
    }
    
    func getEmpleados(req:Request) async throws -> [Empleados] {
        try await Empleados.query(on: req.db)
            .sort(\.$lastName) // Obtiene los empleados ordenados por el campo lastName
            .sort(\.$firstName)
            .all() // Obtiene todos los empleados que haya en la tabla del modelo Empleados
    }
    
//    func getEmpleados2(req:Request) async throws -> Response {
//        let empleados = try await Empleados.query(on: req.db)
//            .sort(\.$lastName) // Obtiene los empleados ordenados por el campo lastName
//            .sort(\.$firstName)
//            .all() // Obtiene todos los empleados que haya en la tabla del modelo Empleados
//
//        //return CustomResponse(httpResponse: Response(status: .found), data: empleados)
//        //return CustomResponseEmpleado(response: Response(status: .ok), empleados: empleados)
//        return Response(status: .ok, body: empleados)
//    }
    
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
        let empleado = try decode(req: req, type: Empleados.self) // La funcion decode es una funcion generica creada manualmente
        try await empleado.create(on: req.db)
        return Response(status: .created)
    }
    
    func updateEmpleado(req:Request) async throws -> Response {
        try Empleados.validate(content: req) // Hace las validaciones de la informacion recibida del front
        let empleado = try req.content.decode(Empleados.self)
        if let empleadoToUpdate = try await Empleados.find(req.parameters.get("empleado", as: UUID.self), on: req.db) {
            if empleado.firstName != empleadoToUpdate.firstName {
                empleadoToUpdate.firstName = empleado.firstName
            }
            if empleado.lastName != empleadoToUpdate.lastName {
                empleadoToUpdate.lastName = empleado.lastName
            }
            if empleado.username != empleadoToUpdate.username {
                empleadoToUpdate.username = empleado.username
            }
            if empleado.email != empleadoToUpdate.email {
                empleadoToUpdate.email = empleado.email
            }
            if empleado.address != empleadoToUpdate.address {
                empleadoToUpdate.address = empleado.address
            }
            if empleado.zipcode != empleadoToUpdate.zipcode {
                empleadoToUpdate.zipcode = empleado.zipcode
            }
            if empleado.avatar != empleadoToUpdate.avatar {
                empleadoToUpdate.avatar = empleado.avatar
            }
            
            try await empleadoToUpdate.update(on: req.db) // Lanza la actualizacion de la informacion en la BBDD
            return Response(status: .ok)
        } else {
            throw Abort(.notFound, reason: "El empleado no existe")
        }
    }

    func deleteEmpleado(req:Request) async throws -> Response {
        if let empleado = try await Empleados.find(req.parameters.get("empleado", as: UUID.self), on: req.db) {
           try await empleado.delete(on: req.db)
            return Response(status: .accepted)
        } else {
            throw Abort(.notFound, reason: "El empleado no existe")
        }
    }
}
