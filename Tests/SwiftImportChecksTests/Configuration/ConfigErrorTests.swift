//
//  ConfigErrorTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

import Testing
@testable import SwiftImportChecks

@Suite("ConfigError Tests")
struct Test {

    @Test("test error description for excludedTarget")
    func excludedTargetErrorDescription() {
        // Given
        let targetName = "ExcludedTarget"
        let error = ConfigError.excludedTarget(targetName: targetName)
        let expectedDescription = "❌ The selected target '\(targetName)' is excluded from the analysis."

        // When
        let description = error.description

        // Then
        #expect(description == expectedDescription)
    }

    @Test("test error description for nilProjectFileName")
    func nilProjectFileNameErrorDescription() {
        // Given
        let error = ConfigError.nilProjectFileName
        let expectedDescription = "❌ The project file name is nil. Please provide a valid project file name."

        // When
        let description = error.description

        // Then
        #expect(description == expectedDescription)
    }

    @Test("test error description for missingProjectAndPackagesPath")
    func missingProjectAndPackagesPathErrorDescription() {
        // Given
        let error = ConfigError.missingProjectAndPackagesPath
        let expectedDescription = "❌ The project path and packages path are both nil. Please provide at least one of them."

        // When
        let description = error.description

        // Then
        #expect(description == expectedDescription)
    }

}
