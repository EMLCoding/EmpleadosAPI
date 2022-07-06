//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor
import Fluent

final class Departments: Model, Content {
    static let schema = "departments"
    
    @ID(custom: .id) var id: Int?
    @Field(key: .name) var name: String
    
    // La siguiente propiedad es solo LOGICA, no esta en la BBDD, es solo para que funcione en Vapor la FK creada en Employees
    @Children(for: \.$department) var employeesDpto: [Employees] // Se pone \.$department porque department es el nombre de la variable con la FK en la tabla Employees
}
