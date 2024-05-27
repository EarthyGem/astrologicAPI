//
//  File.swift
//  
//
//  Created by Errick Williams on 5/26/24.
//

import Foundation
import App
import Vapor
import Logging

@main
struct Run {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }
        try configure(app)
        try await app.run()
    }
}
