//
//  PackagesParser.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

final class PackagesParser {
    let path: String
    let diagramBuilder: any DiagramBuilderProtocol

    init(
        path: String,
        diagramBuilder: any DiagramBuilderProtocol
    ) {
        self.path = path
        self.diagramBuilder = diagramBuilder
    }

    func parsePackages(
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
                diagramBuilder.append(package: package)
                let targets = package.targets
                for target in targets {
                    let config = configs.configurations[target.name] ?? .default
                    print("Package: \(package.name) Target: \(target.name) - Type: \(target.type.rawValue)")
                    guard target.duplicateDependencies.isEmpty else {
                        throw PackagesParser.Error.duplicateDependencies(targetName: target.name, dependencies: target.duplicateDependencies)
                    }
                    var swiftFilesPath: String
                    if let customPath = target.path {
                        // Normalize path: strip leading/trailing slashes to avoid double-slash issues
                        let normalizedPath = customPath
                            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                        // Use explicit path from Package.swift
                        swiftFilesPath = path + "/" + package.name + "/" + normalizedPath
                        // Error if custom path doesn't exist - don't silently scan nothing
                        guard FileManager.default.fileExists(atPath: swiftFilesPath) else {
                            throw PackagesParser.Error.customPathNotFound(
                                targetName: target.name,
                                path: customPath,
                                resolvedPath: swiftFilesPath
                            )
                        }
                    } else {
                        // Fall back to convention: Sources/TargetName or Tests/TargetName
                        swiftFilesPath = path + "/" + package.name + target.type.intermediatePath + target.name
                        // Only fall back to parent directory if convention path doesn't exist
                        if !FileManager.default.fileExists(atPath: swiftFilesPath) {
                            swiftFilesPath = path + "/" + package.name + target.type.intermediatePath
                        }
                    }
                    let swiftFilesParser = SwiftFilesParser(
                        rootURL: URL(fileURLWithPath: swiftFilesPath),
                        packageTargetName: target.name,
                        verbose: verbose
                    )
                    let results = try swiftFilesParser.parseSwiftFiles(config: config, globalExcludedPaths: configs.excludedPaths)
                    let imports = results.processedImports(config: config)
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
        diagramBuilder.generateDiagram()
    }

    private func parsePackageSwift(at path: String) throws -> SwiftPackageFile {
        let sourceFile = try SyntaxParser.parse(URL(fileURLWithPath: path))
        let visitor = PackageSwiftFileVisitor(viewMode: .fixedUp)
        visitor.walk(sourceFile)
        guard let packageName = visitor.packageName else {
            throw Error.failedToParsePackage(path: path)
        }
        return SwiftPackageFile(name: packageName, targets: visitor.targets)
    }
}

extension PackagesParser {
    enum Error: Swift.Error, CustomStringConvertible, Equatable {
        case failedToParsePackage(path: String)
        case duplicateDependencies(targetName: String, dependencies: [String])
        case customPathNotFound(targetName: String, path: String, resolvedPath: String)

        var description: String {
            switch self {
            case .failedToParsePackage(let path):
                "Failed to parse Package.swift at path: \(path)"
            case .duplicateDependencies(let targetName, let dependencies):
                "❌ Target \(targetName) has duplicate dependencies: \(dependencies.joined(separator: ", "))"
            case .customPathNotFound(let targetName, let path, let resolvedPath):
                "❌ Target \(targetName) specifies path: \"\(path)\" but directory not found at: \(resolvedPath)"
            }
        }
    }
}
