//
//  CompositionRootTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

import Testing
@testable import SwiftImportChecks
import Foundation
import XcodeProj
import PathKit

@Suite("CompositionRoot Tests")
struct CompositionRootTests {

    @Test(
        "test root always returns the root path with slash suffix",
        arguments: [
            "/path/to/project/",
            "/path/to/project"
        ]
    )
    func root(rootPath: String) throws {
        // Given, When
        let sut = CompositionRoot(rootPath: rootPath)

        // Then
        #expect(sut.root == "/path/to/project/")
    }

    @Test("test root given rootPath returns pwd")
    func rootDefault() throws {
        // Given, When
        let sut = CompositionRoot()
        let pwd = FileManager.default.currentDirectoryPath

        // Then
        #expect(sut.root == pwd + "/")
    }

    @Test("test run with all arguments nil throws error")
    func run() throws {
        // Given
        let sut = CompositionRoot()

        // When, Then
        #expect(throws: ConfigError.missingProjectAndPackagesPath) {
            try sut.run()
        }
    }

    @Test(
        "test run with invalid projectFileName throws error",
        arguments: [
            "invalidProjectFileName"
        ]
    )
    func runInvalid(projectFileName: String) throws {
        // Given
        let sut = CompositionRoot(projectFileName: projectFileName)
        let pwd = FileManager.default.currentDirectoryPath

        // When, Then
        #expect(throws: XCodeProjError.notFound(path: Path(pwd + "/" + projectFileName))) {
            try sut.run()
        }
    }

    @Test(
        "test run with valid projectFileName print resuts",
        arguments: [
            "Example.xcodeproj"
        ]
    )
    func runValid(projectFileName: String) throws {
        // Given
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            rootPath: rootPath,
            projectFileName: projectFileName
        )

        // When
        try sut.run()

        // Then
        #expect(sut.root == rootPath + "/")
        #expect(sut.projectFileName == projectFileName)
    }
}

private extension URL {
    enum Mock {
        static let exampleXcodeProject = Bundle.module.url(forResource: "Example/Example", withExtension: "xcodeproj")!
    }
}
