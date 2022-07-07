//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 7/7/22.
//

import Vapor
import Fluent

struct LoadDepartments: AsyncMigration {
    func prepare(on database: Database) async throws {
        for dpto in DepartmentNames.allCases {
            try await Departments(name: dpto.rawValue).create(on: database)
        }
    }
    
    func revert(on database: Database) async throws {
        try await database
            .query(Departments.self)
            .filter(\.$name ~~ DepartmentNames.allCases.map(\.rawValue)) // Busca todos los elementos que coincidan con los del enum DepartmentNames
                .delete()
    }
}

enum DepartmentNames: String, CaseIterable {
    case accounting = "Accounting"
    case businessDevelopment = "Business Development"
    case engineering = "Engineering"
    case humanResources = "Human Resources"
    case legal = "Legal"
    case marketing = "Marketing"
    case productManagment = "Product Managment"
}
