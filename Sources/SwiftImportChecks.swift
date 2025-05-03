import ArgumentParser
import Foundation

@main
struct SwiftImportChecks: ParsableCommand {
    //@Option(name: [.short, .customLong("config")], help: "The path of `.sic.yml`.")
    var configurationPath: String? = "/Users/m.karagiorgos/iOSNative/.sic.yml"

    //@Option(name: .shortAndLong, help: "The rootPath of your project. If you omit this, the current directory will be used.")
    var rootPath: String? = "/Users/m.karagiorgos/iOSNative"

    // @Option(name: .shortAndLong, help: "The name of your xcodeproj file. For example: MyProject.xcodeproj")
    var projectFileName: String? //= "Stoiximan.xcodeproj"

    // @Option(name: .shortAndLong, help: "The path of your local packages")
    var spmPackagesPath: String? = "Packages"

    //@Option(name: .shortAndLong, help: "The name of your target. For example: App")
    var targetName: String?

    //@Option(name: .shortAndLong, help: "Flag to enable verbose output.")
    var verbose: Bool = true

    func run() throws {
        let compositionRoot = CompositionRoot(
            configurationPath: configurationPath,
            rootPath: rootPath,
            projectFileName: projectFileName,
            spmPackagesPath: spmPackagesPath,
            targetName: targetName,
            verbose: verbose
        )
        try compositionRoot.run()
    }
}
