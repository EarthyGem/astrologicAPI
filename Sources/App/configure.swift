import Vapor
import Fluent
import FluentPostgresDriver
//import Leaf
// configure.swift

import Vapor

public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure the server to use HTTPS
    app.http.server.configuration.hostname = "localhost"
    app.http.server.configuration.port = 8011 // Change to an available port
    app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
        certificateChain: [.certificate(try .init(file: "/Users/errickwilliams/Desktop/AstrologicAPI/cert.pem", format: .pem))],
        privateKey: .file("/Users/errickwilliams/Desktop/AstrologicAPI/key.pem")
    )

    // Register routes
    try routes(app)
}
