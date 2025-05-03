//
//  ConfigFactory.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 24/4/25.
//

import Foundation

protocol ConfigFactoryProtocol {
    static func make(
        at path: String?,
        fileManager: FileManagerProtocol
    ) throws -> Configurations
}

enum ConfigFactory: ConfigFactoryProtocol {
    static func make(
        at path: String?,
        fileManager: FileManagerProtocol
    ) throws -> Configurations {
        if let path, fileManager.fileExists(atPath: path) {
            return try Configurations.parse(path)
        } else {
            return .default
        }
    }
}
