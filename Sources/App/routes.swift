import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.group("api") { api in
        try api.register(collection: PruebasController())
        try api.register(collection: EmpleadoController())
        try api.register(collection: EmployeeController())
    }
}
