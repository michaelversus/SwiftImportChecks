//
//  ConfigurationTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

import Foundation
import Testing
@testable import SwiftImportChecks

@Suite("Configuration Tests")
struct ConfigurationTests {

    @Test("Parse configuration file with default empty arrays for nil values")
    func parseGivenNilValues() throws {
        // Given
        let configFilePath = URL.Mock.emptyConfigs.relativePath

        // When
        let configurations = try Configurations.parse(configFilePath)

        // Then
        #expect(configurations == Configurations(configurations: ["SICDemoApp": .default]))
    }

    @Test("test exludedPath")
    func excludedPath() throws {
        // Given
        let config = Configuration(
            excluded: ["excludedPath"],
            excludedImports: []
        )

        // When
        let excludedPaths = config.excludedPath(path: "/SwiftImportChecks/SICDemoApp")

        // Then
        #expect(excludedPaths == ["/SwiftImportChecks/SICDemoApp/excludedPath"])
    }
}

private extension URL {
    enum Mock {
        static let emptyConfigs = Bundle.module.url(forResource: "Example/sic_empty", withExtension: "yml")!
    }
}
