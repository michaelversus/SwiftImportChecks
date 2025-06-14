<p align="center">
    <img src="https://img.shields.io/badge/Swift-6.0-red.svg" />
    <img src="https://codecov.io/gh/michaelversus/SwiftImportChecks/branch/main/graph/badge.svg?token=K8H49TQ6SZ"/>
</p>

# 📦 SwiftImportChecks

This is a tool that:
 - enforces only explicitly declared dependencies are imported. (Swift build provides the `--explicit-target-dependency-import-check` flag but unfortunatelly it is not available with `xcodebuild`.)
 - enforces extra rules for forbidden import statements per target.
 - throws errors when you have duplicate dependencies inside Package.swift files.
 - Can create a nice mermaid diagram for your local packages adding some extra config properties.

## 💡 Suggestion

- Use the above tool as a pre-commit hook to avoid increasing your build time.

## 🛠️ Instalation

```bash
brew tap michaelversus/swiftimportchecks https://github.com/michaelversus/SwiftImportChecks
brew install swiftimportchecks
```

## ⚙️ Command line flags
- `-c` lets you specify a path to your .sic.yml configuration file, if you have one
- `-r` sets the path SwiftImportChecks should scan. This defaults to your current working directory.
- `-p` sets the name of your project file (for example MyProject.xcodeproj), if you need one
- `-s` sets the path for a container for your local SPM Packages, if you want to parse those
- `-v` enables verbose output. Default value is false

## ⚙️ Configuration
You can customize the behavior of SwiftImportChecks by creating a **.sic.yml** file in the directory you wish to scan. 
This is a [YAML](https://en.wikipedia.org/wiki/YAML) file that allows you to exclude paths, import statements and packages globally and also per target.
For example, if you need to: 
- exclude `.build` and `.github` paths from scanning
- exclude target `SomeTarget` from scanning
- exclude package `SomePackage` from scanning
- exclude `someInternalPath` only for `SICDemoApp` target from scanning
- exclude `SomeImport` import statements only for `SICDemoApp` target from scanning
- throw error when scan finds `STLT` import statement only for `SICDemoApp` target
- create a mermaid diagram for all your local packages
```yaml
configurations:
  SICDemoApp:
    excluded:
      - someInternalPath
    excludedImports:
        - SomeImport
    forbiddenImports:
        - STLT
excludedPaths:
    - .build
    - .github
excludedTargets:
    - SomeTarget
excludedPackages:
    - SomePackage
diagrams:
    regular:
        layers:
            - Foundation
            - Framework
```

## 🚀 Usage
```bash
swiftimportchecks -c ./.sic.yml -p MyProject.xcodeproj -s Packages
```

## Diagrams guide
SwiftImportChecks can generate a mermaid diagram for your local packages if you follow the below steps:
- Add the `diagrams` property in your .sic.yml file like demonstrated above with the `regular` property and some layers ordered from bottom to top.
- You need to add comments at the top of your local package files like this:
```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// this comment will add ExampleModule inside the Foundation layer
// swiftimportchecks:0:ExampleModule

import PackageDescription

let package = Package(
    name: "ExamplePackage",
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "ExampleModule", dependencies: ["Yams"]),
    ]
)
```
```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// this comment will add OtherModule inside the Framework layer
// swiftimportchecks:1:OtherModule

import PackageDescription

let package = Package(
    name: "OtherPackage",
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "OtherModule", dependencies: ["Yams"]),
    ]
)
```
The above example will create a diagram like this one inside the local packages directory:
![example_diagram](https://github.com/user-attachments/assets/b8371512-c1d7-4417-a434-f6afc9067afc)

[Diagram source code](packages.hmtl)

## Credits
SwiftImportChecks is built on top of 
- Apple's [SwiftSyntax](https://github.com/apple/swift-syntax) library for parsing code, which is available under the Apache License v2.0 with Runtime Library Exception.
- tuist's [XcodeProj](https://github.com/tuist/XcodeProj) library for parsing the xcodeproj file, which is available under the MIT license.
- jpsim's [YAMS](https://github.com/jpsim/Yams) library for parsing yaml files, which is available under the MIT license.

Two amazing projects that I was inspired from to build the above tool are:
- twostraws [Sitrep](https://github.com/twostraws/Sitrep/) a source code analyzer for Swift projects, which is available under the Apache License v2.0 with Runtime Library Exception.
- nikoloutsos [explicitDependencyImportCheck](https://github.com/Nikoloutsos/explicitDependencyImportCheck) a Swift build plugin that enforces clean dependency management, which is available under the MIT license.

Swift, the Swift logo, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.

## 🤝 Contributions

Contributions are more than welcome!
