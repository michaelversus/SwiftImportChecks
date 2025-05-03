//
//  TargetValidator.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 24/4/25.
//

import Foundation

enum TargetValidator {
    static func validate(
        xcodeProjectParser: XcodeProjectParser,
        xcodeProjectPath: String,
        rootPath: String,
        targetName: String,
        config: Configuration,
        globalExcludedPaths: [String],
        verbose: Bool
    ) throws {
        let target = try xcodeProjectParser.parseXcodeProjectTarget(
            at: xcodeProjectPath,
            targetName: targetName,
            root: rootPath,
            verbose: verbose
        )
        let swiftFilesParser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: rootPath),
            target: target,
            verbose: verbose
        )
        let results = try swiftFilesParser.parseSwiftFiles(
            config: config,
            globalExcludedPaths: globalExcludedPaths
        )
        let imports = results.processedImports(config: config)
        if verbose {
            var message = "File imports for target \(targetName):\n"
            for fileImport in Array(imports).sorted() {
                message += "- \(fileImport)\n"
            }
            print(message)
        }
        let diffImports = imports.subtracting(target.dependencies)
        if diffImports.isEmpty {
            print("✅ All imports for target \(targetName) are explicit")
        } else {
            let error = ImplicitDependenciesErrorFactory.make(
                results: results,
                diffImports: diffImports,
                targetName: targetName,
                verbose: verbose
            )
            throw error
        }
    }
}
