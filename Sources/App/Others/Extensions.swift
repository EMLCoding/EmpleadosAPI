//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 5/7/22.
//

import Vapor
import Fluent

extension FieldKey {
    static let username = FieldKey("username")
    static let firstName = FieldKey("first_name")
    static let lastName = FieldKey("last_name")
    static let email = FieldKey("email")
    static let avatar = FieldKey("avatar")
    static let address = FieldKey("address")
    static let zipcode = FieldKey("zipcode")
}
