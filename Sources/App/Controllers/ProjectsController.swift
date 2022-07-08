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
                pid.post("start", use: getProjects)
                pid.post("end", use: getProjects)
                pid.get("employees", use: getProjects)
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
        return .ok
    }
    
    func assignEmployees(req: Request) async throws -> HTTPStatus {
        let content = try req.content.decode(AddProjectsEmployees.self)
        guard let project = try await Projects.find(content.projectID, on: req.db) else { throw Abort(.notFound)}
        for id in content.employees {
            if let employee = try await Employees.find(id, on: req.db) {
                try await project.$employees.attach(employee, method: .ifNotExists, on: req.db) // Realiza la asociacion entre el proyecto y el empleado. Con el ifNotExists comprueba si la relacion no existe ya en la BBDD
            }
        }
        return .ok
    }
    
    func deassignEmployees(req: Request) async throws -> HTTPStatus {
        let content = try req.content.decode(AddProjectsEmployees.self)
        guard let project = try await Projects.find(content.projectID, on: req.db) else { throw Abort(.notFound)}
        for id in content.employees {
            if let employee = try await Employees.find(id, on: req.db), try await project.$employees.isAttached(to: employee, on: req.db) {
                try await project.$employees.detach(employee, on: req.db) // Realiza la des-asociacion entre el proyecto y el empleado.
            }
        }
        return .ok
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
}
