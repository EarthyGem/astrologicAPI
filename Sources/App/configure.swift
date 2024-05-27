import Vapor
import NIOSSL

public func configure(_ app: Application) async throws {
    // Set up your database and other configurations here

    app.logger.info("Starting configuration")

    let certPath = "/Users/administrator/astrologicapi/lilaastrology.com.crt"
    let keyPath = "/Users/administrator/astrologicapi/lilaastrology.com.key"
    //let caBundlePath = "/path/to/your/certificates/ca-bundle.crt"

    app.logger.info("Using certPath: \(certPath)")
    app.logger.info("Using keyPath: \(keyPath)")
  //  app.logger.info("Using caBundlePath: \(caBundlePath)")

    let configuration: TLSConfiguration
    do {
        configuration = TLSConfiguration.makeServerConfiguration(
            certificateChain: try NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
            privateKey: .file(keyPath)
         //   trustRoots: .file(caBundlePath)
        )
    } catch {
        app.logger.critical("Failed to load SSL certificates: \(error)")
        throw error
    }

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 443
    app.http.server.configuration.tlsConfiguration = configuration

    // Register routes
    try routes(app)
}
