//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

// Es una clase necesaria para la relacion n:n de Employees y Projects
final class EmployeesProjects: Model {
    static let schema = "employees+projects"
    
    @ID(key: .id) var id: UUID?
    @Parent(key: .employeeID) var employee: Employees
    @Parent(key: .projectID) var project: Projects
    @OptionalParent(key: .rol) var rol: ProjectRoles?
    @Timestamp(key: .fechaAsignacion, on: .create) var fechaAsignacion: Date?
}


final class ProjectRoles: Model, Content {
    static let schema = "project_roles"
    
    @ID(key: .id) var id: UUID?
    @Field(key: .name) var name: String
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
