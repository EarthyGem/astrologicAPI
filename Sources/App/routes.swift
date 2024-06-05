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

    app.get("planets", "nodal-details") { req -> EventLoopFuture<Response> in
           do {
               guard let dateString = req.query[String.self, at: "date"],
                     let timeString = req.query[String.self, at: "time"],
                     let lat = req.query[Double.self, at: "lat"],
                     let lon = req.query[Double.self, at: "lon"] else {
                   throw Abort(.badRequest, reason: "Missing query parameters")
               }

               // Convert date and time to Date object
               let dateFormatter = ISO8601DateFormatter()
               dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
               guard let date = dateFormatter.date(from: "\(dateString)T\(timeString)Z") else {
                   throw Abort(.badRequest, reason: "Invalid date or time format")
               }

               // Make external API call using Vapor's HTTP client
               let url = "https://lilaastrology.com/planets/nodal-details"
               var urlComponents = URLComponents(string: url)!
               urlComponents.queryItems = [
                   URLQueryItem(name: "date", value: dateString),
                   URLQueryItem(name: "time", value: timeString),
                   URLQueryItem(name: "lat", value: "\(lat)"),
                   URLQueryItem(name: "lon", value: "\(lon)")
               ]

               guard let externalURL = urlComponents.url else {
                   throw Abort(.internalServerError, reason: "Invalid URL")
               }

               let client = req.client
               return client.get(URI(string: externalURL.absoluteString)).flatMapThrowing { clientResponse in
                   guard clientResponse.status == .ok else {
                       throw Abort(.internalServerError, reason: "Failed to fetch data from external API")
                   }

                   // Assuming the external API returns a JSON object
                   guard let body = clientResponse.body else {
                       throw Abort(.internalServerError, reason: "No data in response")
                   }

                   // Decode the JSON response into a NodalDetails object
                   let nodalDetails = try JSONDecoder().decode(NodalDetails.self, from: body)
                   
                   // Process the nodalDetails as needed or return directly
                   return Response(status: .ok, body: .init(data: try JSONEncoder().encode(nodalDetails)))
               }
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

