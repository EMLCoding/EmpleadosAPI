//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor
import Fluent

final class Employees: Model, Content, Validatable {
    // Lo primero de la clase es definir en una propiedad estatica el nombre de la tabla en la BBDD
    static let schema = "employees"
    
    @ID(key: .id) var id: UUID?
    @Field(key: .firstName) var firstName: String
    @Field(key: .lastName) var lastName: String
    @Field(key: .username) var username: String
    @Field(key: .email) var email: String
    @Field(key: .address) var address: String?
    @Field(key: .zipcode) var zipcode: String?
    @Field(key: .avatar) var avatar: String
    @Parent(key: .department) var department: Departments // Relacion con la tabla Departments de tipo obligatorio. Todos los empleados tienen que tener 1 departamento. Cada departamento puede tener 1 o varios empleados.
    // @OptionalParent(key: .department) var department: Departments? -> Esto es lo mismo que lo de la linea anterior pero sin ser un dato obligatorio
    @Siblings(through: EmployeesProjects.self, from: \.$employee, to: \.$project) var projects: [Projects] // Para la relacion n:n con la tabla Projects. El $employee y $project es por el nombre que se le ha dado a las propiedades @Parent de Employees+Projects
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, username: String, email: String, address: String?, zipcode: String?, avatar: String, department: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.address = address
        self.zipcode = zipcode
        self.$department.id = department
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && .count(8...), customFailureDescription: "El email enviado no es válido")
        validations.add("username", as: String.self, is: !.empty && .alphanumeric && .count(5...25))
    }
}
