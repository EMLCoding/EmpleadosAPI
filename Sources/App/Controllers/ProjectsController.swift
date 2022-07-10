//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

struct ProjectsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("projects") { project in
            project.get(use: getProjects)
            project.post(use: newProject)
            project.post("addEmployees", use: assignEmployees)
            project.delete("deleteEmployees", use: deassignEmployees)
            project.group(":projectID") { pid in
                pid.get(use: getProject)
                pid.put(use: updateProject)
                pid.post("start", use: startProject)
                pid.post("end", use: endProject)
                pid.get("employees", use: getEmployeesProject)
            }
        }
        
        routes.group("roles") { rol in
            rol.get(use: getRoles)
            rol.get(use: createRol)
            rol.group(":rolID") { rolID in
                rolID.get(use: getRol)
                rolID.get(use: updateRol)
            }
        }
    }
    
    
    func getProjects(req:Request) async throws -> [Projects] {
        try await Projects
            .query(on: req.db)
            .all()
    }
    
    func newProject(req:Request) async throws -> HTTPStatus {
        let content = try req.content.decode(AddProject.self)
        guard try validateDates(ini: content.initDate, end: content.endDate) else { throw Abort(.badRequest) }
        let newProject = Projects(name: content.name, desc: content.desc, initDate: content.initDate, endDate: content.endDate)
        try await newProject.create(on: req.db)
        return .created
    }
    
    func getProject(req:Request) async throws -> Projects {
        guard let id = req.parameters.get("projectID", as: UUID.self) else { throw Abort(.badRequest) }
        if let project =  try await Projects.find(id, on: req.db) {
            return project
        } else {
            throw Abort(.notFound)
        }
    }
    
    func updateProject(req:Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("projectID", as: UUID.self) else { throw Abort(.badRequest) }
        let content = try req.content.decode(UpdateProject.self)
        guard try validateDates(ini: content.initDate, end: content.endDate) else { throw Abort(.badRequest) }
        guard let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
        
        if let name = content.name, name != project.name {
            project.name = name
        }
        
        if let desc = content.desc, desc != project.desc {
            project.desc = desc
        }
        
        if let initDate = content.initDate, initDate != project.initDate {
            project.initDate = initDate
        }
        
        if let endDate = content.endDate, endDate != project.endDate {
            project.endDate = endDate
        }
        
        try await project.update(on: req.db)
        return .ok
    }
    
    func startProject(req:Request) async throws -> String {
        guard let id = req.parameters.get("projectID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
        project.initDate = .now
        try await project.update(on: req.db)
        return DateFormatter.formatter.string(from: .now)
    }
    
    func endProject(req:Request) async throws -> String {
        guard let id = req.parameters.get("projectID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
        project.endDate = .now
        try await project.update(on: req.db)
        return DateFormatter.formatter.string(from: .now)
    }
    
    func assignEmployees(req: Request) async throws -> Response {
        let content = try req.content.decode(AddProjectsEmployees.self)
        guard let project = try await Projects.find(content.projectID, on: req.db) else { throw Abort(.notFound)}
        
        var errorsRol: [EmployeeRol] = []
        
        for rol in content.employees {
            if let employee = try await Employees.find(rol.idEmployee, on: req.db) {
                try await project.$employees.attach(employee, method: .ifNotExists, on: req.db) // Realiza la asociacion entre el proyecto y el empleado. Con el ifNotExists comprueba si la relacion no existe ya en la BBDD
                
                let empID = try employee.requireID()
                let proID = try project.requireID()
                
                let asociaciones = try await EmployeesProjects
                    .query(on: req.db)
                    .with(\.$project)
                    .with(\.$employee)
                    .group(.and) { group in
                        group
                            .filter(\.$employee.$id == empID)
                            .filter(\.$project.$id == proID)
                    }
                    .all()
                
                if try await ProjectRoles.find(rol.idRol, on: req.db) != nil {
                    if let asociacion = asociaciones.first {
                        asociacion.$rol.id = rol.idRol
                        try await asociacion.update(on: req.db)
                    }
                } else {
                    try await project.$employees.detach(employee, on: req.db)
                    errorsRol.append(rol)
                }
            }
        }
        
        if errorsRol.isEmpty {
            return Response(status: .ok)
        } else {
            // Lo del HTTPHeaders es para que la respuesta se envie como un json. Sin eso se enviaria como texto plano
            return Response(status: .created, headers: HTTPHeaders([("Content-Type", "application/json")]), body: Response.Body(data: try JSONEncoder().encode(errorsRol)))
        }
    }
    
    func deassignEmployees(req: Request) async throws -> HTTPStatus {
        let content = try req.content.decode(AddProjectsEmployees.self)
        guard let project = try await Projects.find(content.projectID, on: req.db) else { throw Abort(.notFound)}
        for rol in content.employees {
            if let employee = try await Employees.find(rol.idEmployee, on: req.db), try await project.$employees.isAttached(to: employee, on: req.db) {
                try await project.$employees.detach(employee, on: req.db) // Realiza la des-asociacion entre el proyecto y el empleado.
            }
        }
        return .ok
    }
    
    func getEmployeesProject(req:Request) async throws -> [Employees] {
        guard let id = req.parameters.get("projectID", as: UUID.self) else { throw Abort(.notFound) }
        guard let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
        return try await project.$employees.query(on: req.db).with(\.$department).all()
    }
    
    func validateDates(ini: Date?, end: Date?) throws -> Bool {
        if let ini = ini {
            if ini <= .now {
                throw Abort(.badRequest, reason: "La fecha de inicio no puede ser anterior a la actual")
            }
        }
        
        if let end = end {
            if end <= .now {
                throw Abort(.badRequest, reason: "La fecha de fin no puede ser anterior a la actual")
            }
        }
        
        if let ini = ini, let end = end {
            if ini > end {
                throw Abort(.badRequest, reason: "La fecha de inicio no puede ser posterior a la fecha de fin")
            }
        }
        return true
    }
    
    func getRoles(req:Request) async throws -> [ProjectRoles] {
        try await ProjectRoles.query(on: req.db).all()
    }
    
    func createRol(req:Request) async throws -> ProjectRoles {
        let content = try req.content.decode(CreateDepartments.self)
        if try await ProjectRoles.query(on: req.db).filter(\.$name, .custom("ILIKE"), content.name).all().count == 0 {
            let newRol = ProjectRoles(name: content.name)
            try await newRol.create(on: req.db)
            return newRol
        } else {
            throw Abort(.badRequest, reason: "Ya existe un rol con el nombre: \(content.name)")
        }
    }
    
    func getRol(req:Request) async throws -> ProjectRoles {
        guard let id = req.parameters.get("rolID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let roles = try await ProjectRoles.find(id, on: req.db) else { throw Abort(.notFound) }
        return roles
    }
    
    func updateRol(req:Request) async throws -> ProjectRoles {
        let content = try req.content.decode(CreateDepartments.self)
        guard let id = req.parameters.get("rolID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let rol = try await ProjectRoles.find(id, on: req.db) else { throw Abort(.notFound) }
        if content.name.lowercased() != rol.name.lowercased() {
            rol.name = content.name.capitalized
            try await rol.update(on: req.db)
            return rol
        } else {
            throw Abort(.badRequest, reason: "El rol ya se llama asi")
        }
        
    }
}
