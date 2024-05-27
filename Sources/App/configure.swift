import Vapor
import PostgresKit
import NIOSSL

public func configure(_ app: Application) throws {
    app.logger.info("Starting configuration")

    let certPath = "/etc/letsencrypt/live/lilaastrology.com/fullchain.pem"
    let keyPath = "/etc/letsencrypt/live/lilaastrology.com/privkey.pem"

    app.logger.info("Using certPath: \(certPath)")
    app.logger.info("Using keyPath: \(keyPath)")

    let tlsConfiguration: TLSConfiguration
    do {
        tlsConfiguration = TLSConfiguration.makeServerConfiguration(
            certificateChain: try NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
            privateKey: .file(keyPath)
        )
    } catch {
        app.logger.critical("Failed to load SSL certificates: \(error)")
        throw error
    }

    app.http.server.configuration.tlsConfiguration = tlsConfiguration
    app.http.server.configuration.supportVersions = [.one, .two]

    // Database configuration
    app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: try .forClient(trustRoots: .default)
    )), as: .psql)

    // Migrations
    app.migrations.add(CreateTodo())

    // Register routes
    try routes(app)
}
