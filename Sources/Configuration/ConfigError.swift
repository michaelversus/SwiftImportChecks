//
//  ConfigError.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 24/4/25.
//

enum ConfigError: Error, CustomStringConvertible, Equatable {
    case excludedTarget(targetName: String)
    case nilProjectFileName
    case missingProjectAndPackagesPath

    var description: String {
        switch self {
        case .excludedTarget(let targetName):
            return "❌ The selected target '\(targetName)' is excluded from the analysis."
        case .nilProjectFileName:
            return "❌ The project file name is nil. Please provide a valid project file name."
        case .missingProjectAndPackagesPath:
            return "❌ The project path and packages path are both nil. Please provide at least one of them."
        }
    }
}
