//
//  Results.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation

public struct Results {
    /// All the files detected by this scan
    var files: [SwiftFile]

    /// All the imports detected across all files, stored with frequency
    var imports = NSCountedSet()
}

extension Results {
    func processedImports(config: Configuration) -> Set<String> {
        let result = self.imports
            .allObjects
            .sorted { first, second in self.imports.count(for: first) > self.imports.count(for: second) }
            .compactMap { value -> String? in
                guard
                    let importString = value as? String,
                    !config.excludedImports.contains(importString),
                    !SystemImports.all.contains(importString)
                else { return nil }
                return importString.removingCommentsWhitespaceAndDotSuffix()
            }
        return Set(result)
    }
}
