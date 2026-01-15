import CheThingsMCPCore

// Entry point
let server = try await CheThingsMCPServer()
try await server.run()
