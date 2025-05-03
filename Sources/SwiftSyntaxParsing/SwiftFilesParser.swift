//
//  SwiftFilesParser.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation

struct SwiftFilesParser {
    let rootURL: URL
    let target: Target?
    let packageTargetName: String?
    let verbose: Bool

    init(
        rootURL: URL,
        target: Target? = nil,
        packageTargetName: String? = nil,
        verbose: Bool
    ) {
        self.rootURL = rootURL
        self.target = target
        self.packageTargetName = packageTargetName
        self.verbose = verbose
    }

    func parseSwiftFiles(config: Configuration, globalExcludedPaths: [String]) throws -> Results {
        let files = findFiles(
            excludedPaths: config.excludedPath(path: rootURL.path),
            globalExludedPaths: globalExcludedPaths
        )
        print("🎯 Target: \(target?.name ?? packageTargetName ?? "unknown") linked files count: \(files.count)")
        let (parsedFiles, _) = try parse(files: files)
        if verbose {
            print("🎯 Target: \(target?.name ?? packageTargetName ?? "unknown") parsed files count: \(parsedFiles.count)")
        }
        let results = try collate(parsedFiles)
        return results
    }

    private func findFiles(
        excludedPaths: [String],
        globalExludedPaths: [String]
    ) -> [URL] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: nil)
        var fileURLs = [URL]()
        while let objectURL = enumerator?.nextObject() as? URL {
            guard
                objectURL.hasDirectoryPath == false,
                !objectURL.containsOneOf(paths: globalExludedPaths)
            else {
                continue
            }
            let isExcluded = excludedPaths.contains { path in
                objectURL.deletingLastPathComponent().relativePath.hasPrefix(path)
            }
            guard
                isExcluded == false,
                objectURL.pathExtension == "swift"
            else { continue }
            if let target, target.swiftFiles.contains(objectURL.path()) {
                fileURLs.append(objectURL)
            } else if target == nil {
                fileURLs.append(objectURL)
            }
        }
        return fileURLs
    }

    private func parse(files: [URL]) throws -> (files: [SwiftFile], failures: [URL]) {
        var parsedFiles = [SwiftFile]()
        var failures = [URL]()

        for file in files {
            if let file = try? SwiftFile(url: file) {
                parsedFiles.append(file)
            } else {
                failures.append(file)
            }
        }
        return (parsedFiles, failures)
    }

    public func collate(_ scannedFiles: [SwiftFile]) throws -> Results {
        let results = Results(files: scannedFiles)
        for file in scannedFiles {
            let fileImports = file.results.imports.filter{ !SystemImports.all.contains($0) }
            if !fileImports.isEmpty {
                results.imports.addObjects(from: fileImports)
            }
        }
        return results
    }
}

