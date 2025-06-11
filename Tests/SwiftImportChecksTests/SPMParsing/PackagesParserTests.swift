//
//  PackagesParserTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 1/5/25.
//

import Foundation
import Testing
@testable import SwiftImportChecks

@Suite("PackagesParser Tests")
struct PackagesParserTests {
    let configs = Configurations.default
    let verbose = false
    let diagramBuilder = MockDiagramBuilder()

    @Test("test parsePackages given invalid path skips parsing")
    func parsePackagesGivenInvalidPath() throws {
        // Given
        let path: String = "invalidPath"
        var messages: [String] = []
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: verbose,
            print: { messages.append($0) }
        )

        // Then
        #expect(messages == [])
    }

    @Test("test parsePackages given valid path without packages skips parsing")
    func parsePackagesGivenValidPathWithoutPackages() throws {
        // Given
        let path: String = URL.Mock.exampleDir.relativePath
        var messages: [String] = []
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: verbose,
            print: { messages.append($0) }
        )

        // Then
        #expect(messages == [])
    }

    @Test("test parsePackages given valid path with excluded Package name skips")
    func parsePackagesGivenValidPathWithExcludedPackageName() throws {
        // Given
        let path: String = URL.Mock.secondPackageFileDir.relativePath
        var messages: [String] = []
        let configs = Configurations(
            excludedPackages: ["SwiftImportChecks"]
        )
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: verbose,
            print: { messages.append($0) }
        )

        // Then
        #expect(messages == [])
    }

    @Test("test parsePackages given valid path with valid Package name and without files")
    func parsePackagesGivenValidPathWithValidPackageNameAndWithoutFiles() throws {
        // Given
        let path: String = URL.Mock.packageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages = [
            "Package: SwiftImportChecks Target: SwiftImportChecks - Type: regular",
            "✅ All imports for target SwiftImportChecks are explicit"
        ]
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: verbose,
            print: { messages.append($0) }
        )

        // Then
        #expect(messages == expectedMessages)
    }

    @Test("test parsePackages given valid path with valid Package name and with files with implicit imports")
    func parsePackagesGivenValidPathWithValidPackageNameAndWithFilesWithImplicitImports() throws {
        // Given
        let path: String = URL.Mock.failurePackageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages: [String] = [
            "Package: FailurePackage Target: FailureModule - Type: regular"
        ]
        var expectedDescription = "❌ Target FailureModule contains implicit dependencies:\n"
        expectedDescription += "- ❌ Alamofire\n"
        expectedDescription += "- ❌ SwiftImportChecks\n"
        let sut = makeSUT(path: path)

        // When, Then
        #expect(
            throws: ImplicitDependenciesError(description: expectedDescription),
            performing: {
                try sut.parsePackages(
                    configs: configs,
                    verbose: verbose,
                    print: { messages.append($0) }
                )
            }
        )
        #expect(messages == expectedMessages)
    }

    @Test("test parsePackages given valid path with valid Package name and duplicate dependencies throws error")
    func parsePackagesGivenValidPathWithValidPackageNameAndDuplicateDependencies() throws {
        // Given
        let path: String = URL.Mock.duplicatesPackageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages: [String] = [
            "Package: SwiftImportChecks Target: SwiftImportChecks - Type: regular"
        ]
        let sut = makeSUT(path: path)

        // When, Then
        #expect(
            throws: PackagesParser.Error.duplicateDependencies(targetName: "SwiftImportChecks", dependencies: ["SomeDependency"]),
            performing: {
                try sut.parsePackages(
                    configs: configs,
                    verbose: verbose,
                    print: { messages.append($0) }
                )
            }
        )
        #expect(messages == expectedMessages)
    }
}

extension PackagesParserTests {
    func makeSUT(path: String) -> PackagesParser {
        PackagesParser(
            path: path,
            diagramBuilder: diagramBuilder
        )
    }
}

private extension URL {
    enum Mock {
        static let exampleDir = Bundle.module.url(forResource: "Example/NoPackage/sic", withExtension: "yml")!.deletingLastPathComponent()
        static let packageFileDir = Bundle.module.url(forResource: "Example/Package/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let secondPackageFileDir = Bundle.module.url(forResource: "Example/SecondPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let duplicatesPackageFileDir = Bundle.module.url(forResource: "Example/DuplicatesPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let failurePackageFileDir = Bundle.module.url(forResource: "Example/FailurePackage/Package", withExtension: "swift")!.deletingLastPathComponent()
    }
}
