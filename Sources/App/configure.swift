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

    // Esto es para que siempre se manejen las fechas con el mismo formato
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601 // Formato que almacena las fechas con hora, minutos y segundos
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
    // Ejemplo si se quisiera usar el decoder con fechas que no mantienen la hora
    let decoderFecha = JSONDecoder()
    decoderFecha.dateDecodingStrategy = .formatted(.formatter)
    let encoderFecha = JSONEncoder()
    encoderFecha.dateEncodingStrategy = .formatted(.formatter)
    
    // Se establece el codificador global para los JSON
    ContentConfiguration.global.use(decoder: decoderFecha, for: .json)
    ContentConfiguration.global.use(encoder: encoderFecha, for: .json)
    
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
