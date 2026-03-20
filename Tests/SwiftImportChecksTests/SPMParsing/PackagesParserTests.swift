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

    @Test("test parsePackages uses default print closure when not provided")
    func parsePackagesUsesDefaultPrint() throws {
        // Given: Call without explicit print to exercise default parameter
        let path = URL.Mock.packageFileDir.relativePath
        let sut = makeSUT(path: path)

        // When: Uses default print (no custom closure)
        try sut.parsePackages(configs: configs, verbose: false)
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

    @Test("test parsePackages given valid path with custom path argument uses correct target path")
    func parsePackagesGivenValidPathWithCustomPathArgument() throws {
        // Given
        // This test verifies that:
        // 1. Files in Sources/Core are scanned for TestModule (has CoreDependency import)
        // 2. Files in Sources/UI are NOT scanned (has UndeclaredDependency import that would fail)
        // 3. Files in CustomTests are scanned for TestModuleTests (testTarget with custom path)
        let path: String = URL.Mock.customPathPackageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages: [String] = [
            "Package: CustomPathPackage Target: TestModule - Type: regular",
            "✅ All imports for target TestModule are explicit",
            "Package: CustomPathPackage Target: TestModuleTests - Type: test",
            "✅ All imports for target TestModuleTests are explicit"
        ]
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: verbose,
            print: { messages.append($0) }
        )

        // Then
        // If Sources/UI was incorrectly scanned, this would fail with UndeclaredDependency error
        #expect(messages == expectedMessages)
    }

    @Test("test parsePackages given custom path that does not exist throws error")
    func parsePackagesGivenCustomPathNotFoundThrowsError() throws {
        // Given
        let path: String = URL.Mock.invalidCustomPathPackageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages: [String] = [
            "Package: InvalidPathPackage Target: MissingModule - Type: regular"
        ]
        let sut = makeSUT(path: path)

        // When, Then
        #expect(
            throws: PackagesParser.Error.customPathNotFound(
                targetName: "MissingModule",
                path: "Sources/DoesNotExist",
                resolvedPath: path + "/Sources/DoesNotExist"
            ),
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

    @Test("test parsePackages given path with excluded path component skips package")
    func parsePackagesGivenExcludedPathSkips() throws {
        // Given: Package.swift inside a path that contains "excluded" (in excludedPaths)
        let path = URL.Mock.excludedPathPackageFileDir.relativePath
        var messages: [String] = []
        let configs = Configurations(excludedPaths: ["excluded"])
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: false,
            print: { messages.append($0) }
        )

        // Then: Package is skipped, no processing
        #expect(messages == [])
    }

    @Test("test parsePackages given excludeAllSPMTestTargets skips test targets")
    func parsePackagesGivenExcludeAllSPMTestTargetsSkipsTestTargets() throws {
        // Given: CustomPathPackage has TestModule (regular) and TestModuleTests (test)
        let path = URL.Mock.customPathPackageFileDir.relativePath
        var messages: [String] = []
        let configs = Configurations(excludeAllSPMTestTargets: true)
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: false,
            print: { messages.append($0) }
        )

        // Then: Only TestModule processed, TestModuleTests skipped
        let expectedMessages = [
            "Package: CustomPathPackage Target: TestModule - Type: regular",
            "✅ All imports for target TestModule are explicit"
        ]
        #expect(messages == expectedMessages)
    }

    @Test("test parsePackages given invalid Package.swift throws failedToParsePackage")
    func parsePackagesGivenInvalidPackageThrows() throws {
        // Given: Package.swift with no valid Package declaration
        let path = URL.Mock.invalidPackageFileDir.relativePath
        var messages: [String] = []
        let sut = makeSUT(path: path)

        // When, Then
        #expect(
            throws: PackagesParser.Error.failedToParsePackage(path: path + "/Package.swift"),
            performing: {
                try sut.parsePackages(
                    configs: configs,
                    verbose: false,
                    print: { messages.append($0) }
                )
            }
        )
    }

    @Test("test parsePackages given verbose true prints import listing")
    func parsePackagesGivenVerbosePrintsImports() throws {
        // Given: CustomPathPackage has non-system imports (CoreDependency, XCTest)
        let path = URL.Mock.customPathPackageFileDir.relativePath
        var messages: [String] = []
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: true,
            print: { messages.append($0) }
        )

        // Then: Output includes "Imports for target" and " - " lines for each import
        #expect(messages.contains { $0.contains("Imports for target TestModule") })
        #expect(messages.contains { $0.contains(" - ") })
    }

    @Test("test parsePackages given custom path when primary path exists uses primary")
    func parsePackagesGivenCustomPathPrimaryExists() throws {
        // Given: PrimaryPathPackage has path "Sources/Foo" which exists at package root
        let path = URL.Mock.primaryPathPackageFileDir.relativePath
        var messages: [String] = []
        let expectedMessages = [
            "Package: PrimaryPathPackage Target: Foo - Type: regular",
            "✅ All imports for target Foo are explicit"
        ]
        let sut = makeSUT(path: path)

        // When
        try sut.parsePackages(
            configs: configs,
            verbose: false,
            print: { messages.append($0) }
        )

        // Then
        #expect(messages == expectedMessages)
    }

    @Test("test PackagesParser Error descriptions")
    func packagesParserErrorDescriptions() {
        let path = "/some/path"
        #expect(
            PackagesParser.Error.failedToParsePackage(path: path).description ==
            "Failed to parse Package.swift at path: \(path)"
        )
        #expect(
            PackagesParser.Error.duplicateDependencies(targetName: "T", dependencies: ["D1", "D2"]).description ==
            "❌ Target T has duplicate dependencies: D1, D2"
        )
        #expect(
            PackagesParser.Error.customPathNotFound(
                targetName: "T",
                path: "p",
                resolvedPath: "/r"
            ).description ==
            "❌ Target T specifies path: \"p\" but directory not found at: /r"
        )
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
        static let customPathPackageFileDir = Bundle.module.url(forResource: "Example/CustomPathPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let invalidCustomPathPackageFileDir = Bundle.module.url(forResource: "Example/InvalidCustomPathPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let invalidPackageFileDir = Bundle.module.url(forResource: "Example/InvalidPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let primaryPathPackageFileDir = Bundle.module.url(forResource: "Example/PrimaryPathPackage/Package", withExtension: "swift")!.deletingLastPathComponent()
        static let excludedPathPackageFileDir: URL = {
            let packageURL = Bundle.module.url(forResource: "Example/ExcludedPathPackage/excluded/ExcludedPackage/Package", withExtension: "swift")!
            return packageURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        }()
    }
}
