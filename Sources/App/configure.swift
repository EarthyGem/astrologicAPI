import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.http.server.configuration.port = 8011
    
    app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    )), as: .psql)

  //  app.migrations.add(CreateTodo())

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)

    // Register routes
    try routes(app)
}
