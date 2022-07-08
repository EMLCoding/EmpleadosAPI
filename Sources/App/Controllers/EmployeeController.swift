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
            emp.post(use: newEmpleado)
            emp.group(":empID") { empID in
                empID.get(use: getEmployee)
                empID.put(use: updateEmployee)
                empID.delete(use: deleteEmployee)
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
    
    func newEmpleado(req:Request) async throws -> HTTPStatus {
        let new = try req.content.decode(AddEmployee.self)
        if try await Departments.find(new.department, on: req.db) == nil {
            throw Abort(.badRequest, reason: "El ID de departamento no es correcto.")
        }
        let newEmployee = Employees(firstName: new.firstName, lastName: new.lastName, username: new.username, email: new.email, address: new.address, zipcode: new.zipcode, avatar: new.avatar, department: new.department)
        try await newEmployee.create(on: req.db)
        try await newEmployee.$department.load(on: req.db)
        return .ok
    }
    
    func getEmployee(req: Request) async throws -> Employees {
        guard let id = req.parameters.get("empID", as: UUID.self) else { throw Abort(.badRequest) }
        if let employee = try await Employees.find(id, on: req.db) {
            try await employee.$department.load(on: req.db) // Para cargar toda la informacion del departamento, sino solo saca el ID
            return employee
        } else {
            throw Abort(.notFound)
        }
    }
    
    func updateEmployee(req:Request) async throws -> Employees {
        guard let id = req.parameters.get("empID", as: UUID.self),
                let employee = try await Employees.find(id, on: req.db)
        else { throw Abort(.badRequest) }
        let update = try req.content.decode(UpdateEmployee.self)
        if let firstName = update.firstName, firstName != employee.firstName {
            employee.firstName = firstName
        }
        if let lastName = update.lastName, lastName != employee.lastName {
            employee.lastName = lastName
        }
        if let username = update.username, username != employee.username {
            employee.username = username
        }
        if let address = update.address, address != employee.address {
            employee.address = address
        }
        if let email = update.email, email != employee.email {
            employee.email = email
        }
        if let zipcode = update.zipcode, zipcode != employee.zipcode {
            employee.zipcode = zipcode
        }
        if let avatar = update.avatar, avatar != employee.avatar {
            employee.avatar = avatar
        }
        if let department = update.department, department != employee.$department.id {
            guard try await Departments.find(department, on: req.db) != nil else { throw Abort(.notFound, reason: "Departamento no encontrado")}
            employee.$department.id = department
        }
        
        // Para hacer la validacion de los datos se codifica el objeto employee en un json para que se haga la comprobacion con el validate de la clase Employees
        let jsonData = try JSONEncoder().encode(employee)
        if let json = String(data: jsonData, encoding: .utf8) {
            try Employees.validate(json: json)
        }
        
        try await employee.update(on: req.db)
        return employee
    }
    
    func deleteEmployee(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("empID", as: UUID.self) else { throw Abort(.badRequest) }
        if let employee = try await Employees.find(id, on: req.db) {
            try await employee.delete(on: req.db)
            return .accepted
        } else {
            throw Abort(.notFound)
        }
    }
}
