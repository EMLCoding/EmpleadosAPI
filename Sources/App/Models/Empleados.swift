//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent

final class Empleados: Model, Content, Validatable {
    // Lo primero de la clase es definir en una propiedad estatica el nombre de la tabla en la BBDD
    static let schema = "empleados"
    
    @ID(key: .id) var id: UUID?
    @Field(key: .firstName) var firstName: String
    @Field(key: .lastName) var lastName: String
    @Field(key: .username) var username: String
    @Field(key: .email) var email: String
    @Field(key: .address) var address: String?
    @Field(key: .zipcode) var zipcode: String?
    @Field(key: .avatar) var avatar: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && .count(8...), customFailureDescription: "El email enviado no es válido")
        validations.add("username", as: String.self, is: !.empty && .alphanumeric && .count(5...25))
    }
}


