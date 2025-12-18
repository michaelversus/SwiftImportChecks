// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomPathPackage",
    dependencies: [],
    targets: [
        .target(
            name: "TestModule",
            dependencies: ["CoreDependency"],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "TestModuleTests",
            dependencies: ["XCTest"],
            path: "CustomTests"
        )
    ]
)
