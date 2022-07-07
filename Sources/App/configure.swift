import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder -> Descomentar para que se pueda acceder a los documentos de la carpeta Public desde el codigo
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    // register routes
    try routes(app)
    
    // Carga de migraciones
    app.migrations.add(CreateEmpleados())
    app.migrations.add(CreateDepartment())
    app.migrations.add(CreateEmployees())
    app.migrations.add(CreateProjects())
    app.migrations.add(CreateEmployeesProjects())
    app.migrations.add(LoadDepartments())
}
