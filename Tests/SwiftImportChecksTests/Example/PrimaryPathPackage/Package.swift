// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PrimaryPathPackage",
    dependencies: [],
    targets: [
        .target(
            name: "Foo",
            dependencies: [],
            path: "Sources/Foo"
        )
    ]
)
