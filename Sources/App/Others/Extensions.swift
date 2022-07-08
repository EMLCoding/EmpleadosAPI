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
    static let name = FieldKey("name")
    static let department = FieldKey("department")
    static let description = FieldKey("description")
    static let initDate = FieldKey("init_date")
    static let endDate = FieldKey("end_date")
    static let employeeID = FieldKey("employee_id")
    static let projectID = FieldKey("project_id")
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
