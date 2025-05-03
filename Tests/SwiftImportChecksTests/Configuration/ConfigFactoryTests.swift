//
//  ConfigFactoryTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

import Foundation
import Testing
@testable import SwiftImportChecks

@Suite("ConfigFactory Tests")
struct ConfigFactoryTests {
    var fileManager = FileManagerMock()

    @Test("test make given nil path returns default config")
    func makeGivenNilPath() throws {
        // Given
        let path: String? = nil

        // When
        let configs = try ConfigFactory.make(
            at: path,
            fileManager: fileManager
        )

        // Then
        #expect(configs == .default)
    }

    @Test("test make given invalid path returns default config")
    func makeGivenInvalidPath() throws {
        // Given
        let path: String = "invalidPath"

        // When
        let configs = try ConfigFactory.make(
            at: path,
            fileManager: fileManager
        )

        // Then
        #expect(configs == .default)
    }

    @Test("test make given valid path but invalid config throws error")
    func makeGivenValidPath() throws {
        // Given
        let path: String = "validPath"
        fileManager.fileExistsReturnValue = true
        var parsingError = false

        // When
        do {
            _ = try ConfigFactory.make(
                at: path,
                fileManager: fileManager
            )
        } catch {
            parsingError = true
        }

        // Then
        #expect(parsingError == true)
    }

    @Test("test make given valid path returns valid config")
    func makeGivenValidPathReturnsValidConfig() throws {
        // Given
        let path: String = URL.Mock.exampleConfigs.relativePath
        fileManager.fileExistsReturnValue = true

        // When
        let configs = try ConfigFactory.make(
            at: path,
            fileManager: fileManager
        )

        // Then
        #expect(configs == .mock())
    }
}

extension Configurations {
    static func mock() -> Configurations {
        Configurations(
            configurations: [
                "SICDemoApp": Configuration(
                    excluded: [
                        ".build",
                        ".github",
                        ".githooks",
                        ".git",
                        ".gitlab",
                        ".swiftpm"
                    ],
                    excludedImports: ["Foundation"]
                )
            ],
            excludedTargets: ["Tests"],
            excludedPackages: ["PackageTest"]
        )
    }
}

private extension URL {
    enum Mock {
        static let exampleConfigs = Bundle.module.url(forResource: "Example/sic", withExtension: "yml")!
    }
}
