import Vapor
import NIOSSL

public func configure(_ app: Application) throws {
    // Serve files from the /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Set up TLS configuration
    let certPath = "/Users/administrator/astrologicapi/liliaastrology_com.crt"
    let keyPath = "/Users/administrator/astrologicapi/newkey.key"
    
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

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 443
    app.http.server.configuration.tlsConfiguration = tlsConfiguration

    // Register routes
    try routes(app)
}
