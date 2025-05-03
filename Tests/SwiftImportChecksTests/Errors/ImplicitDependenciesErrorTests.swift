//
//  ImplicitDependenciesErrorTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

@testable import SwiftImportChecks
import Testing
import Foundation

@Suite("ImplicitDependenciesError Tests")
struct ImplicitDependenciesErrorTests {

    @Test("test make given empty files returns error description with target name and dependencies")
    func testMakeGivenEmptyFiles() {
        // Given
        let targetName = "SomeTarget"
        let imports = Set(["Dependency1", "Dependency2"])
        let results = Results(files: [])
        let verbose = false
        var expectedDescription = "❌ Target SomeTarget contains implicit dependencies:\n"
        expectedDescription += "- ❌ Dependency1\n"
        expectedDescription += "- ❌ Dependency2\n"
        let expectedError = ImplicitDependenciesError(description: expectedDescription)

        // When
        let error = ImplicitDependenciesErrorFactory.make(
            results: results,
            diffImports: imports,
            targetName: targetName,
            verbose: verbose
        )

        // Then
        #expect(error == expectedError)
    }

    @Test("test make given empty DiffImports returns error description with target name only")
    func testMakeGivenEmptyDiffImports() {
        // Given
        let targetName = "SomeTarget"
        let imports = Set<String>()
        let results = Results(files: [])
        let verbose = false
        let expectedDescription = "❌ Target SomeTarget contains implicit dependencies:\n"
        let expectedError = ImplicitDependenciesError(description: expectedDescription)

        // When
        let error = ImplicitDependenciesErrorFactory.make(
            results: results,
            diffImports: imports,
            targetName: targetName,
            verbose: verbose
        )

        // Then
        #expect(error == expectedError)
    }

    @Test("test make given valid DiffImports and files returns expected error description")
    func testMakeGivenValidInput() throws {
        // Given
        let targetName = "SomeTarget"
        let imports = Set(["Dependency1", "Dependency2"])
        let url = URL.Mock.swiftTestFile
        var file = try SwiftFile(url: url)
        let fileVisitor = FileVisitor(viewMode: .fixedUp)
        fileVisitor.imports = ["Dependency1", "Dependency3"]
        file.results = fileVisitor
        let results = Results(
            files: [file]
        )
        let verbose = true
        var expectedDescription = "❌ Target SomeTarget contains implicit dependencies:\n"
        expectedDescription += "- ❌ Dependency1 imported at:\n"
        expectedDescription += "-- \(url.relativePath)\n"
        expectedDescription += "- ❌ Dependency2 imported at:\n"
        let expectedError = ImplicitDependenciesError(description: expectedDescription)

        // When
        let error = ImplicitDependenciesErrorFactory.make(
            results: results,
            diffImports: imports,
            targetName: targetName,
            verbose: verbose
        )

        // Then
        #expect(error == expectedError)
    }
}

private extension URL {
    enum Mock {
        static let swiftTestFile = Bundle.module.url(forResource: "Example/SwiftTestFile", withExtension: "swift")!
    }
}
