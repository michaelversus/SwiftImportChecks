//
//  SwiftImportChecksTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

import Testing
@testable import SwiftImportChecks

@Suite("SwiftImportChecks Tests")
struct SwiftImportChecksTests {

    @Test("test run with all options nil throws error")
    func run() throws {
        // Given
        var sut = SwiftImportChecks()
        sut.configurationPath = nil
        sut.rootPath = nil
        sut.projectFileName = nil
        sut.spmPackagesPath = nil
        sut.targetName = nil
        sut.verbose = false

        // When, Then
        #expect(throws: ConfigError.missingProjectAndPackagesPath) {
            try sut.run()
        }
    }

    @Test("test run given valid spmPackagesPath options prints results")
    func runWithValidSPMPath() throws {
        // Given
        var sut = SwiftImportChecks()
        sut.configurationPath = nil
        sut.rootPath = nil
        sut.projectFileName = nil
        sut.spmPackagesPath = "SwiftImportChecks"
        sut.targetName = nil
        sut.verbose = false

        // When, Then
        try sut.run()
    }
}
