//
//  ConfigFactoryMock.swift
//  SwiftImportChecks
//
//  Created for testing CompositionRoot.
//

@testable import SwiftImportChecks

enum ConfigFactoryMock: ConfigFactoryProtocol {
    nonisolated(unsafe) static var configsToReturn: Configurations = .default
    nonisolated(unsafe) static var errorToThrow: (any Error)?

    static func make(at path: String?, fileManager: FileManagerProtocol) throws -> Configurations {
        if let error = errorToThrow {
            throw error
        }
        return configsToReturn
    }

    static func reset() {
        configsToReturn = .default
        errorToThrow = nil
    }
}
