import Vapor
import NIOSSL

public func configure(_ app: Application) async throws {
    // Set up your database and other configurations here

    // Configure SSL
    let certificatePath = "/Users/administrator/astrologicapi/cert.pem"
    let privateKeyPath = "/Users/administrator/astrologicapi/key.pem"
    let configuration = TLSConfiguration.makeServerConfiguration(
        certificateChain: try NIOSSLCertificate.fromPEMFile(certificatePath).map { .certificate($0) },
        privateKey: .file(privateKeyPath)
    )

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 443
    app.http.server.configuration.tlsConfiguration = configuration

    // Register routes
    try routes(app)
}
