import Vapor
import NIOSSL

public func configure(_ app: Application) async throws {
    // Set up your database and other configurations here

    // Configure SSL
    let certPath = "/Users/errickwilliams/Desktop/AstrologicAPI/cert.pem"
    let keyPath = "/Users/errickwilliams/Desktop/AstrologicAPI/key.pem"
    let configuration = TLSConfiguration.makeServerConfiguration(
        certificateChain: try NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
        privateKey: .file(keyPath)
    )

    app.http.server.configuration.hostname = "207.254.119.79"
    app.http.server.configuration.port = 443
    app.http.server.configuration.tlsConfiguration = configuration

    // Register routes
    try routes(app)
}
