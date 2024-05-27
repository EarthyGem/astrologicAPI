import Vapor
import NIOSSL

public func configure(_ app: Application) async throws {
    // Set up your database and other configurations here

    // Configure SSL
    let certPath = "/etc/letsencrypt/live/lilaastrology.com/fullchain.pem"
       let keyPath = "/etc/letsencrypt/live/lilaastrology.com/privkey.pem"

    let configuration = TLSConfiguration.makeServerConfiguration(
        certificateChain: try NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
        privateKey: .file(keyPath)
    )

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 443
    app.http.server.configuration.tlsConfiguration = configuration

    // Register routes
    try routes(app)
}
