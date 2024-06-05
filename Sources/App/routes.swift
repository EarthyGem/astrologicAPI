import Vapor
import Fluent
import SwiftEphemeris

func routes(_ app: Application) throws {
    // Route to get planetary positions
    app.get("planets") { req -> EventLoopFuture<Response> in
        do {
            // Extract and validate query parameters
            guard let dateString = req.query[String.self, at: "date"],
                  let timeString = req.query[String.self, at: "time"],
                  let lat = req.query[Double.self, at: "lat"],
                  let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing required parameters: date, time, lat, lon")
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

    // Route to get planetary power scores
    app.get("planets", "power-scores") { req -> EventLoopFuture<Response> in
        do {
            guard let dateString = req.query[String.self, at: "date"],
                  let timeString = req.query[String.self, at: "time"],
                  let lat = req.query[Double.self, at: "lat"],
                  let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing required parameters: date, time, lat, lon")
            }

            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
            guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                throw Abort(.badRequest, reason: "Invalid date or time format")
            }

            guard let chartCake = ChartCake(birthDate: date, latitude: lat, longitude: lon) else {
                throw Abort(.internalServerError, reason: "Failed to generate chart.")
            }

            let powerScores = chartCake.natal.getTotalPowerScoresForPlanets().map { "\($0.key.keyName) strength: \($0.value)" }
            let response = PowerScoresResponse(scores: powerScores)

            app.logger.info("Power scores response: \(response)")

            return req.eventLoop.makeSucceededFuture(try Response(status: .ok, body: .init(data: JSONEncoder().encode(response))))
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }

    // Route to get the nodal details
    app.get("planets", "nodal-details") { req -> EventLoopFuture<Response> in
        do {
            guard let dateString = req.query[String.self, at: "date"],
                  let timeString = req.query[String.self, at: "time"],
                  let lat = req.query[Double.self, at: "lat"],
                  let lon = req.query[Double.self, at: "lon"] else {
                throw Abort(.badRequest, reason: "Missing required parameters: date, time, lat, lon")
            }

            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
            guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                throw Abort(.badRequest, reason: "Invalid date or time format")
            }

            guard let chartCake = ChartCake(birthDate: date, latitude: lat, longitude: lon) else {
                throw Abort(.internalServerError, reason: "Failed to generate chart.")
            }

            let nodalDetails = chartCake.calculateSouthNode()
            let response = NodalDetails(config: nodalDetails)

            app.logger.info("Nodal details response: \(response)")

            return req.eventLoop.makeSucceededFuture(try Response(status: .ok, body: .init(data: JSONEncoder().encode(response))))
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
