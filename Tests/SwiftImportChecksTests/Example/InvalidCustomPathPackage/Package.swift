// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InvalidPathPackage",
    dependencies: [],
    targets: [
        .target(
            name: "MissingModule",
            dependencies: [],
            path: "Sources/DoesNotExist"
        )
    ]
)
