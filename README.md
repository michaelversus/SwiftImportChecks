<p align="center">
    <img src="https://img.shields.io/badge/Swift-6.0-red.svg" />
    <img src="https://codecov.io/gh/michaelversus/SwiftImportChecks/graph/badge.svg?token=K8H49TQ6SZ"/>
</p>

# 📦 SwiftImportChecks

This is a tool that enforces only explicitly declared dependencies are imported and also can enforce extra rules for forbidden import statements per target.
Swift build provides the `--explicit-target-dependency-import-check` flag but unfortunatelly it is not available with `xcodebuild`.

## 💡 Suggestion

- Use the above tool as a pre-commit hook to avoid increasing your build time.

## 🛠️ Instalation

- Remove existing tap if present (ignore this if you never tapped michaelversus/formulae before):
`brew untap michaelversus/swiftimportchecks https://github.com/michaelversus/SwiftImportChecks`
- Add tap again
`brew tap michaelversus/swiftimportchecks https://github.com/michaelversus/SwiftImportChecks`
- Install
`brew install swiftimportchecks`

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
```

## 🚀 Usage
```bash
swiftimportchecks -c ./.sic.yml -p MyProject.xcodeproj -s Packages
```

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
