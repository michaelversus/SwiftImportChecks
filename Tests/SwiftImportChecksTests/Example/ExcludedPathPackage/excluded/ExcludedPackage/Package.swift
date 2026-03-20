// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ExcludedPackage",
    dependencies: [],
    targets: [
        .target(name: "ExcludedModule", dependencies: [])
    ]
)
