//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

struct EmployeeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("employees") { emp in
            emp.get(use: getEmployees)
            emp.post(use: getEmployees)
            emp.group(":empID") { empID in
                empID.get(use: getEmployees)
                empID.put(use: getEmployees)
                empID.delete(use: getEmployees)
                empID.get("projects", use: getEmployees)
            }
        }
        routes.get("getDptoEmployee", ":id", use: getDepartmentEmployee)
        routes.group("department") { routes in
            routes.get(use: getEmployees)
            routes.post(use: getEmployees)
            routes.group(":dptoID") { dpto in
                dpto.get("empleados", use: getEmployees)
                dpto.put(use: getEmployees)
            }
        }
    }
    
    func getEmployees(req:Request) async throws -> [Employees] {
        try await Employees
            .query(on: req.db)
            .with(\.$department) // Con esto sacaria en la propiedad departament todo el objeto departament. sin esto solo devolveria la propiedad id del objeto Department
            .all()
    }
    
    func getDepartmentEmployee(req:Request) async throws -> Departments {
        guard let id = req.parameters.get("id", as: UUID.self) else { throw Abort(.notFound) }
        guard let empleado = try await Employees
            .query(on: req.db)
            .with(\.$department)
            .filter(\.$id == id)
            .first() else { throw Abort(.notFound) }
        
        return empleado.department
    }
    
    /// Este metodo hace lo mismo que el metodo getDepartmentEmployee, pero sin usar el '.with'
    func getDepartmentEmployeeAlt(req:Request) async throws -> Departments {
        guard let id = req.parameters.get("id", as: UUID.self) else { throw Abort(.notFound) }
        guard let empleado = try await Employees
            .query(on: req.db)
            .filter(\.$id == id)
            .first() else { throw Abort(.notFound) }
        
        return try await empleado.$department.get(on: req.db)
    }
    
    /// Funcion de ejemplo de como se obtendría la relacion del departamento de un empleado con otra tabla. Por ejemplo si un departamento estuviera vinculado a un area y quisieramos sacar esa informacion junto a la del empleado...
//    func getDepartmentEmployeeNested(req:Request) async throws -> Departments {
//        guard let id = req.parameters.get("id", as: UUID.self) else { throw Abort(.notFound) }
//        guard let empleado = try await Employees
//            .query(on: req.db)
//            .with(\.$department) { department in
//                department.with(\.$area)
//            }
//            .filter(\.$id == id)
//            .first() else { throw Abort(.notFound) }
//
//        return empleado.department
//    }
}
