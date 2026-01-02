// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OpenWith",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "OpenWith", targets: ["OpenWith"])
    ],
    targets: [
        .executableTarget(
            name: "OpenWith",
            path: "OpenWith"
        )
    ]
)
