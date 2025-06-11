// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftImportChecks",
    dependencies: [],
    targets: [
        .target(
            name: "SwiftImportChecks",
            dependencies: [
                "SomeDependency",
                "SomeDependency"
            ]
        )
    ]
)
