// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RootCause",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "RootCauseCore", targets: ["RootCauseCore"]),
    ],
    targets: [
        .target(
            name: "RootCauseCore",
            path: "Sources/RootCauseCore"
        ),
        .testTarget(
            name: "RootCauseCoreTests",
            dependencies: ["RootCauseCore"],
            path: "Tests/RootCauseCoreTests"
        ),
    ]
)
