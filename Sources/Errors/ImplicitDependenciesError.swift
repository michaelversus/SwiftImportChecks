//
//  ImplicitDependenciesError.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 24/4/25.
//

struct ImplicitDependenciesError: Error, CustomStringConvertible, Equatable {
    let description: String
}

enum ImplicitDependenciesErrorFactory {
    static func make(
        results: Results,
        diffImports: Set<String>,
        targetName: String,
        verbose: Bool
    ) -> ImplicitDependenciesError {
        var description = "❌ Target \(targetName) contains implicit dependencies:\n"
        for diffImport in Array(diffImports).sorted() {
            let urls = results.files
                .filter {
                    $0.results.imports.contains(diffImport)
                }
                .compactMap {
                    $0.url
                }

            description += verbose ? "- ❌ \(diffImport) imported at:\n" : "- ❌ \(diffImport)\n"
            if verbose {
                for url in urls {
                    description += "-- \(url.relativePath)\n"
                }
            }
        }
        return ImplicitDependenciesError(description: description)
    }
}
