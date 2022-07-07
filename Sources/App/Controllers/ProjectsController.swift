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
            project.get(use: getEmployees)
            project.post(use: getEmployees)
            project.group(":projectID") { pid in
                pid.get(use: getEmployees)
                pid.put(use: getEmployees)
                pid.post("start", use: getEmployees)
                pid.post("end", use: getEmployees)
                pid.get("employees", use: getEmployees)
                pid.post("addEmployees", use: getEmployees)
                pid.post("addEmployee", use: getEmployees)
                pid.delete("removeEmployee", use: getEmployees)
            }
        }
    }
    
    
    func getEmployees(req:Request) async throws -> [Employees] {
        try await Employees
            .query(on: req.db)
            .with(\.$department) // Con esto sacaria en la propiedad departament todo el objeto departament. sin esto solo devolveria la propiedad id del objeto Department
            .all()
    }
}
