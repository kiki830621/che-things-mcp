// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CheThingsMCP",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CheThingsMCPCore",
            targets: ["CheThingsMCPCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.10.0")
    ],
    targets: [
        // Core library containing ThingsManager, models, and server logic
        .target(
            name: "CheThingsMCPCore",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Sources/CheThingsMCPCore"
        ),
        // Executable entry point
        .executableTarget(
            name: "CheThingsMCP",
            dependencies: ["CheThingsMCPCore"],
            path: "Sources/CheThingsMCP"
        ),
        // Unit tests
        .testTarget(
            name: "CheThingsMCPTests",
            dependencies: ["CheThingsMCPCore"],
            path: "Tests/CheThingsMCPTests"
        )
    ]
)
