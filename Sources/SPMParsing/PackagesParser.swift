//
//  PackagesParser.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//
import Foundation

enum PackagesParser {

    static func parsePackages(
        at path: String,
        configs: Configurations,
        verbose: Bool,
        print: @escaping (String) -> Void = { msg in print(msg) }
    ) throws {
        let fileManager = FileManager.default

        let enumerator = fileManager.enumerator(atPath: path)
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix("Package.swift") {
                let fullPath = path + "/" + file
                let components = fullPath.split(separator: "/").map(String.init)
                let excludedPaths = Set(configs.excludedPaths)
                let componentsSet = Set(components)
                guard excludedPaths.intersection(componentsSet).isEmpty else { continue }
                let package = try parsePackageSwift(at: fullPath)
                guard !configs.excludedPackages.contains(package.name) else { continue }
                let targets = mapFileToTargets(file: package)
                for target in targets {
                    let config = configs.configurations[target.name] ?? .default
                    print("Package: \(package.name) Target: \(target.name) - Type: \(target.type.rawValue)")
                    var swiftFilesPath = path + "/" + package.name + target.type.intermediatePath + target.name
                    debugPrint(swiftFilesPath)
                    if !FileManager.default.fileExists(atPath: swiftFilesPath) {
                        swiftFilesPath = path + "/" + package.name + target.type.intermediatePath
                    }
                    let swiftFilesParser = SwiftFilesParser(
                        rootURL: URL(fileURLWithPath: swiftFilesPath),
                        packageTargetName: target.name,
                        verbose: verbose
                    )
                    let results = try swiftFilesParser.parseSwiftFiles(config: config, globalExcludedPaths: configs.excludedPaths)
                    let imports = results.processedImports(config: config)
                    debugPrint("Imports for target \(target.name):\n")
                    if verbose {
                        print("Imports for target \(target.name):\n")
                        for importName in imports {
                            print(" - \(importName)\n")
                        }
                    }
                    let diffImports = imports.filter { !SystemImports.all.contains($0) }.subtracting(target.dependencies)
                    if diffImports.isEmpty {
                        print("✅ All imports for target \(target.name) are explicit")
                    } else {
                        let error = ImplicitDependenciesErrorFactory.make(
                            results: results,
                            diffImports: diffImports,
                            targetName: target.name,
                            verbose: verbose
                        )
                        throw error
                    }
                }
            }
        }
    }

    static func mapFileToTargets(file: SwiftPackageFile) -> [SwiftPackageTarget] {
        file.targets.map { target in
            SwiftPackageTarget(
                name: target.name,
                type: target.type,
                dependencies: Set(target.dependencies.compactMap { $0.name() })
            )
        }
    }

    static func parsePackageSwift(at path: String) throws -> SwiftPackageFile {
        let url = URL(fileURLWithPath: path)
        let output =  try ShellHandler.shell("swift package --package-path \(url.deletingLastPathComponent().path) dump-package")
        guard let data = output?.data(using: .utf8) else {
            throw CommandFlowError.shellOutputNil
        }
        print("Parsing Package.swift at path: \(path)")
        let decoder = JSONDecoder()
        let package = try decoder.decode(SwiftPackageFile.self, from: data)
        return package
    }
}
