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
@MainActor
struct CompositionRootTests {

    // MARK: - root

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

    @Test("test root given nil rootPath uses fileManager currentDirectoryPath")
    func rootWithNilUsesFileManagerPwd() throws {
        // Given
        let customPwd = "/custom/working/directory"
        let fileManager = FileManagerMock(currentDirectoryPath: customPwd)

        // When - init resolves nil to fileManager.currentDirectoryPath
        let sut = CompositionRoot(rootPath: nil, fileManager: fileManager)

        // Then
        #expect(sut.root == customPwd + "/")
    }

    @Test("test root when rootPath stored as nil uses fileManager currentDirectoryPath")
    func rootStoredNilUsesFileManagerPwd() throws {
        // Given: use test init to store nil rootPath (exercises ?? fallback in root property)
        let customPwd = "/custom/fallback/path"
        let fileManager = FileManagerMock(currentDirectoryPath: customPwd)

        // When
        let sut = CompositionRoot(
            configurationPath: nil,
            rootPath: nil,
            fileManager: fileManager,
            storeRootPathAsProvided: true
        )

        // Then - root property uses fileManager.currentDirectoryPath when rootPath is nil
        #expect(sut.root == customPwd + "/")
    }

    @Test("test init with storeRootPathAsProvided false uses fileManager when rootPath nil")
    func initStoreRootPathFalseUsesFileManager() throws {
        // Given: test init with storeRootPathAsProvided: false - same as main init
        let customPwd = "/custom/when/false"
        let fileManager = FileManagerMock(currentDirectoryPath: customPwd)

        // When
        let sut = CompositionRoot(
            configurationPath: nil,
            rootPath: nil,
            fileManager: fileManager,
            storeRootPathAsProvided: false
        )

        // Then - rootPath resolved via fileManager
        #expect(sut.rootPath == customPwd)
        #expect(sut.root == customPwd + "/")
    }

    @Test("test root given rootPath returns pwd")
    func rootDefault() throws {
        // Given, When
        let sut = CompositionRoot()
        let pwd = FileManager.default.currentDirectoryPath

        // Then
        #expect(sut.root == pwd + "/")
    }

    // MARK: - init

    @Test("test init stores all parameters correctly")
    func initStoresParameters() throws {
        // Given
        let configPath = "/config.yml"
        let root = "/project/root"
        let projectFile = "App.xcodeproj"
        let packagesPath = "Packages"
        let target = "App"
        let fileManager = FileManagerMock(currentDirectoryPath: "/pwd")

        // When
        let sut = CompositionRoot(
            configurationPath: configPath,
            rootPath: root,
            projectFileName: projectFile,
            spmPackagesPath: packagesPath,
            targetName: target,
            configFactory: ConfigFactoryMock.self,
            fileManager: fileManager,
            verbose: true
        )

        // Then
        #expect(sut.configurationPath == configPath)
        #expect(sut.rootPath == root)
        #expect(sut.projectFileName == projectFile)
        #expect(sut.spmPackagesPath == packagesPath)
        #expect(sut.targetName == target)
        #expect(sut.verbose == true)
    }

    @Test("test init given nil rootPath uses fileManager currentDirectoryPath")
    func initNilRootPathUsesFileManager() throws {
        // Given
        let customPwd = "/init/pwd"
        let fileManager = FileManagerMock(currentDirectoryPath: customPwd)

        // When
        let sut = CompositionRoot(rootPath: nil, fileManager: fileManager)

        // Then
        #expect(sut.rootPath == customPwd)
    }

    // MARK: - run

    @Test("test run with all arguments nil throws error")
    func runMissingProjectAndPackages() throws {
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
        "test run with valid projectFileName succeeds",
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

    @Test("test run with spmPackagesPath only succeeds")
    func runPackagesFlowOnly() throws {
        // Given
        let exampleDir = URL.Mock.exampleDir.path
        let sut = CompositionRoot(
            rootPath: exampleDir,
            spmPackagesPath: "Package"
        )

        // When
        try sut.run()

        // Then
        #expect(sut.root == exampleDir + "/")
        #expect(sut.spmPackagesPath == "Package")
    }

    @Test("test run with both projectFileName and spmPackagesPath runs both flows")
    func runBothFlows() throws {
        // Given
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            rootPath: rootPath,
            projectFileName: "Example.xcodeproj",
            spmPackagesPath: "Package"
        )

        // When
        try sut.run()

        // Then - both flows complete without throwing
        #expect(sut.projectFileName == "Example.xcodeproj")
        #expect(sut.spmPackagesPath == "Package")
    }

    @Test("test run with excluded targetName throws")
    func runExcludedTargetThrows() throws {
        // Given
        ConfigFactoryMock.reset()
        ConfigFactoryMock.configsToReturn = Configurations(excludedTargets: ["SICDemoApp"])
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            rootPath: rootPath,
            projectFileName: "Example.xcodeproj",
            targetName: "SICDemoApp",
            configFactory: ConfigFactoryMock.self
        )

        // When, Then
        #expect(throws: ConfigError.excludedTarget(targetName: "SICDemoApp")) {
            try sut.run()
        }
    }

    @Test("test run with targetName filters to single target")
    func runTargetNameFiltersTargets() throws {
        // Given
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            rootPath: rootPath,
            projectFileName: "Example.xcodeproj",
            targetName: "SICDemoApp"
        )

        // When
        try sut.run()

        // Then - only SICDemoApp validated
        #expect(sut.targetName == "SICDemoApp")
    }

    @Test("test run with target-specific configuration uses target config")
    func runTargetSpecificConfig() throws {
        // Given: config has target-specific Configuration for SICDemoApp
        ConfigFactoryMock.reset()
        ConfigFactoryMock.configsToReturn = Configurations(
            configurations: ["SICDemoApp": Configuration(excludedImports: [])]
        )
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            rootPath: rootPath,
            projectFileName: "Example.xcodeproj",
            configFactory: ConfigFactoryMock.self
        )

        // When
        try sut.run()

        // Then - projectFlow uses target-specific config
        #expect(sut.projectFileName == "Example.xcodeproj")
    }

    @Test("test run with configFactory throwing propagates error")
    func runConfigFactoryThrows() throws {
        // Given
        ConfigFactoryMock.reset()
        ConfigFactoryMock.errorToThrow = ConfigError.forbiddenImportsFound
        let sut = CompositionRoot(
            projectFileName: "Example.xcodeproj",
            configFactory: ConfigFactoryMock.self
        )

        // When, Then
        #expect(throws: ConfigError.forbiddenImportsFound) {
            try sut.run()
        }
        ConfigFactoryMock.reset()
    }

    @Test("test run with configurationPath absolute uses path as-is")
    func runConfigurationPathAbsolute() throws {
        // Given: absolute path is used as-is (no root prefix)
        ConfigFactoryMock.reset()
        let rootPath = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let absoluteConfigPath = "/absolute/path/to/config.yml"

        // When - ConfigFactoryMock returns default, projectFlow runs
        let sut = CompositionRoot(
            configurationPath: absoluteConfigPath,
            rootPath: rootPath,
            projectFileName: "Example.xcodeproj",
            configFactory: ConfigFactoryMock.self
        )
        try sut.run()

        // Then - run succeeds; absolute path passed to configFactory without root prefix
        #expect(sut.configurationPath == absoluteConfigPath)
    }

    @Test("test run with configurationPath relative resolves against root")
    func runConfigurationPathRelative() throws {
        // Given: sic.yml exists at Example/sic.yml
        let exampleRoot = URL.Mock.exampleXcodeProject.deletingLastPathComponent().path
        let sut = CompositionRoot(
            configurationPath: "sic.yml",
            rootPath: exampleRoot,
            projectFileName: "Example.xcodeproj",
            configFactory: ConfigFactory.self
        )

        // When
        try sut.run()

        // Then - relative path resolved and run succeeds
        #expect(sut.configurationPath == "sic.yml")
    }

    @Test("test run with config fallback to .sic.yml in packages parent")
    func runConfigFallbackToSicYml() throws {
        // Given: no configurationPath, spmPackagesPath set, fallback .sic.yml exists
        let exampleDir = URL.Mock.exampleDir.path
        let packagesPath = "Package"
        let packagesFullPath = exampleDir + "/" + packagesPath
        let projectRoot = (packagesFullPath as NSString).deletingLastPathComponent
        let fallbackPath = (projectRoot + "/.sic.yml" as NSString).standardizingPath
        let fileManager = FileManagerMock(
            currentDirectoryPath: exampleDir,
            fileExistsPaths: [fallbackPath: true]
        )
        ConfigFactoryMock.reset()

        // When
        let sut = CompositionRoot(
            configurationPath: nil,
            rootPath: exampleDir,
            spmPackagesPath: packagesPath,
            configFactory: ConfigFactoryMock.self,
            fileManager: fileManager
        )
        try sut.run()

        // Then - fallback triggered, fileExists called for fallback path
        #expect(fileManager.actions.contains { if case .fileExists(atPath: let p) = $0 { return p.contains(".sic.yml") } else { return false } })
    }

    @Test("test run with config fallback when .sic.yml not found in packages parent")
    func runConfigFallbackWhenSicYmlNotFound() throws {
        // Given: fallback block entered but fileExists returns false for .sic.yml
        let exampleDir = URL.Mock.exampleDir.path
        let packagesPath = "Package"
        let fileManager = FileManagerMock(currentDirectoryPath: exampleDir, fileExistsReturnValue: false)
        ConfigFactoryMock.reset()

        // When - resolvedConfigPath stays nil, configFactory gets nil
        let sut = CompositionRoot(
            configurationPath: nil,
            rootPath: exampleDir,
            spmPackagesPath: packagesPath,
            configFactory: ConfigFactoryMock.self,
            fileManager: fileManager
        )
        try sut.run()

        // Then - run succeeds with default config
        #expect(sut.spmPackagesPath == packagesPath)
    }

    @Test("test run with config path set but file missing triggers fallback to .sic.yml")
    func runConfigPathSetButFileMissingTriggersFallback() throws {
        // Given: configurationPath set but file doesn't exist, spmPackagesPath set, fallback .sic.yml exists
        let exampleDir = URL.Mock.exampleDir.path
        let packagesPath = "Package"
        let packagesFullPath = exampleDir + "/" + packagesPath
        let projectRoot = (packagesFullPath as NSString).deletingLastPathComponent
        let fallbackPath = (projectRoot + "/.sic.yml" as NSString).standardizingPath
        let resolvedConfigPath = (exampleDir + "/missing.yml" as NSString).standardizingPath
        let fileManager = FileManagerMock(
            currentDirectoryPath: exampleDir,
            fileExistsPaths: [resolvedConfigPath: false, fallbackPath: true]
        )
        ConfigFactoryMock.reset()

        // When
        let sut = CompositionRoot(
            configurationPath: "missing.yml",
            rootPath: exampleDir,
            spmPackagesPath: packagesPath,
            configFactory: ConfigFactoryMock.self,
            fileManager: fileManager
        )
        try sut.run()

        // Then - fallback used when primary config missing
        #expect(fileManager.actions.contains { if case .fileExists(atPath: let p) = $0 { return p.contains("missing") } else { return false } })
    }

    @Test("test run with verbose true passes to flows")
    func runVerboseTrue() throws {
        // Given
        let exampleDir = URL.Mock.exampleDir.path
        let sut = CompositionRoot(
            rootPath: exampleDir,
            spmPackagesPath: "Package",
            verbose: true
        )

        // When
        try sut.run()

        // Then
        #expect(sut.verbose == true)
    }
}

private extension URL {
    enum Mock {
        static let exampleXcodeProject = Bundle.module.url(forResource: "Example/Example", withExtension: "xcodeproj")!
        static let exampleDir = Bundle.module.url(forResource: "Example/sic", withExtension: "yml")!.deletingLastPathComponent()
    }
}
