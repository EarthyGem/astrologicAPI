import Vapor
import NIOSSL

public func configure(_ app: Application) throws {
    // Serve files from the /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Set up TLS configuration with correct paths
    let certPath = "/Users/administrator/astrologicapi/lilaastrology_com.crt"
    let keyPath = "/Users/administrator/astrologicapi/newkey.key"
    
    // Verify certificate and key files exist
    let certExists = FileManager.default.fileExists(atPath: certPath)
    let keyExists = FileManager.default.fileExists(atPath: keyPath)
    
    app.logger.info("Certificate path: \(certPath) exists: \(certExists)")
    app.logger.info("Key path: \(keyPath) exists: \(keyExists)")

    guard certExists else {
        app.logger.critical("Certificate file does not exist at path: \(certPath)")
        throw Abort(.internalServerError, reason: "Certificate file not found.")
    }
    
    guard keyExists else {
        app.logger.critical("Private key file does not exist at path: \(keyPath)")
        throw Abort(.internalServerError, reason: "Private key file not found.")
    }

    let tlsConfiguration: TLSConfiguration
    do {
        let certificates = try NIOSSLCertificate.fromPEMFile(certPath)
        app.logger.info("Loaded certificates: \(certificates)")
        let certificateChain = certificates.map { NIOSSLCertificateSource.certificate($0) }
        let privateKey = try NIOSSLPrivateKeySource.file(keyPath)
        app.logger.info("Loaded private key")
        tlsConfiguration = TLSConfiguration.makeServerConfiguration(certificateChain: certificateChain, privateKey: privateKey)
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
