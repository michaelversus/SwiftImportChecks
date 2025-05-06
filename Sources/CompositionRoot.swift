//
//  CompositionRoot.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//
import Foundation

struct CompositionRoot {
    let configurationPath: String?
    let rootPath: String?
    let projectFileName: String?
    let spmPackagesPath: String?
    let targetName: String?
    let configFactory: ConfigFactoryProtocol.Type
    let fileManager: FileManagerProtocol
    let verbose: Bool

    var root: String {
        let rootPath = rootPath ?? fileManager.currentDirectoryPath
        if rootPath.hasSuffix("/") {
            return rootPath
        } else {
            return rootPath + "/"
        }
    }

    init(
        configurationPath: String? = nil,
        rootPath: String? = nil,
        projectFileName: String? = nil,
        spmPackagesPath: String? = nil,
        targetName: String? = nil,
        configFactory: ConfigFactoryProtocol.Type = ConfigFactory.self,
        fileManager: FileManagerProtocol = FileManager.default,
        verbose: Bool = false
    ) {
        self.configurationPath = configurationPath
        self.rootPath = rootPath ?? fileManager.currentDirectoryPath
        self.projectFileName = projectFileName
        self.spmPackagesPath = spmPackagesPath
        self.targetName = targetName
        self.configFactory = configFactory
        self.fileManager = fileManager
        self.verbose = verbose
    }

    func run() throws {
        if projectFileName == nil && spmPackagesPath == nil {
            throw ConfigError.missingProjectAndPackagesPath
        }
        let configs = try configFactory.make(at: configurationPath, fileManager: fileManager)
        if let projectFileName {
            try projectFlow(
                configs: configs,
                projectFileName: projectFileName,
                verbose: verbose
            )
        }
        if let spmPackagesPath {
            try packagesFlow(configs: configs, packagesPath: spmPackagesPath)
        }
    }

    private func packagesFlow(
        configs: Configurations,
        packagesPath: String
    ) throws {
        let packagesFullPath = root + packagesPath
        try PackagesParser.parsePackages(
            at: packagesFullPath,
            configs: configs,
            verbose: verbose
        )
    }

    private func projectFlow(
        configs: Configurations,
        projectFileName: String,
        verbose: Bool
    ) throws {
        let xcodeProjectParser = XcodeProjectParser()
        let xcodeProjectPath = root + projectFileName
        var targetNames = try xcodeProjectParser.parseXcodeProjectTargetNames(
            at: xcodeProjectPath
        )
        if let targetName, !configs.excludedTargets.contains(targetName) {
            targetNames = [targetName]
        } else if let targetName, configs.excludedTargets.contains(targetName) {
            throw ConfigError.excludedTarget(targetName: targetName)
        }
        for targetName in targetNames {
            let targetConfig = configs.configurations[targetName] ?? Configuration.default
            try TargetValidator.validate(
                xcodeProjectParser: xcodeProjectParser,
                xcodeProjectPath: xcodeProjectPath,
                rootPath: root,
                targetName: targetName,
                config: targetConfig,
                globalExcludedPaths: configs.excludedPaths,
                verbose: verbose
            )
        }
    }
}
