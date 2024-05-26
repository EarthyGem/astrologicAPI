import Vapor
import Fluent
import SwiftEphemeris

func routes(_ app: Application) throws {
    // Existing route to get planetary positions
    app.get("planets") { req -> EventLoopFuture<Response> in
        do {
            guard let dateString = req.query[String.self, at: "date"] else {
                throw Abort(.badRequest, reason: "Missing date parameter")
            }
            guard let timeString = req.query[String.self, at: "time"] else {
                throw Abort(.badRequest, reason: "Missing time parameter")
            }
            guard let lat = req.query[Double.self, at: "lat"] else {
                throw Abort(.badRequest, reason: "Missing latitude parameter")
            }
            guard let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing longitude parameter")
            }

            // Convert date and time to Date object
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
            guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                throw Abort(.badRequest, reason: "Invalid date or time format")
            }

            // Calculate planetary positions using Swiss Ephemeris
            guard let chartCake = ChartCake(birthDate: date, latitude: lat, longitude: lon) else {
                throw Abort(.internalServerError, reason: "Failed to generate chart.")
            }

            let planetPositions = chartCake.natal.planets.map { "\($0.body.keyName) at \($0.formatted)" }
            let response = PlanetaryPositionsResponse(planets: planetPositions)

            app.logger.info("Planetary positions response: \(response)")

            return req.eventLoop.makeSucceededFuture(try Response(status: .ok, body: .init(data: JSONEncoder().encode(response))))
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }

    // New route to get total power scores for planets
    app.get("planets", "power-scores") { req -> EventLoopFuture<Response> in
        do {
            guard let dateString = req.query[String.self, at: "date"] else {
                throw Abort(.badRequest, reason: "Missing date parameter")
            }
            guard let timeString = req.query[String.self, at: "time"] else {
                throw Abort(.badRequest, reason: "Missing time parameter")
            }
            guard let lat = req.query[Double.self, at: "lat"] else {
                throw Abort(.badRequest, reason: "Missing latitude parameter")
            }
            guard let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing longitude parameter")
            }

            // Convert date and time to Date object
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
            guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                throw Abort(.badRequest, reason: "Invalid date or time format")
            }

            // Calculate planetary positions using Swiss Ephemeris
            guard let chartCake = ChartCake(birthDate: date, latitude: lat, longitude: lon) else {
                throw Abort(.internalServerError, reason: "Failed to generate chart.")
            }

            // Add logging for inputs
            app.logger.info("Calculating power scores for date: \(dateString), time: \(timeString), lat: \(lat), lon: \(lon)")

            let powerScores = chartCake.natal.getTotalPowerScoresForPlanets().map { "\($0.key.keyName) strength: \($0.value)" }
            let response = PowerScoresResponse(scores: powerScores)

            // Add logging for outputs
            app.logger.info("Power scores calculated: \(response)")

            return req.eventLoop.makeSucceededFuture(try Response(status: .ok, body: .init(data: JSONEncoder().encode(response))))
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }

    // New route to get the nodal details
    app.get("planets", "nodal-details") { req -> EventLoopFuture<Response> in
        do {
            guard let dateString = req.query[String.self, at: "date"] else {
                throw Abort(.badRequest, reason: "Missing date parameter")
            }
            guard let timeString = req.query[String.self, at: "time"] else {
                throw Abort(.badRequest, reason: "Missing time parameter")
            }
            guard let lat = req.query[Double.self, at: "lat"] else {
                throw Abort(.badRequest, reason: "Missing latitude parameter")
            }
            guard let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing longitude parameter")
            }

            // Convert date and time to Date object
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
            guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                throw Abort(.badRequest, reason: "Invalid date or time format")
            }

            // Calculate planetary positions using Swiss Ephemeris
            guard let chartCake = ChartCake(birthDate: date, latitude: lat, longitude: lon) else {
                throw Abort(.internalServerError, reason: "Failed to generate chart.")
            }

            // Calculate nodal details
            let nodalDetails = chartCake.calculateSouthNode()
            let response = NodalDetails(config: nodalDetails)
            return req.eventLoop.makeSucceededFuture(try Response(status: .ok, body: .init(data: JSONEncoder().encode(nodalDetails))))
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }
}

// Structs for responses
struct PlanetaryPositionsResponse: Content {
    var planets: [String]
}

struct PowerScoresResponse: Content {
    var scores: [String]
}
struct NodalDetails: Content {
    var config: String
}

