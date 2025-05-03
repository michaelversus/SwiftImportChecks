//
//  XcodeProjectParser.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 16/4/25.
//

import PathKit
import XcodeProj

struct XcodeProjectParser {

    enum Error: Swift.Error, CustomStringConvertible, Equatable {
        case invalidProjectPath
        case invalidRootPath
        case invalidTargetName

        var description: String {
            switch self {
            case .invalidProjectPath:
                return "❌ Invalid project path."
            case .invalidRootPath:
                return "❌ Invalid root path."
            case .invalidTargetName:
                return "❌ Invalid target name."
            }
        }
    }

    func parseXcodeProjectTargetNames(
        at path: String?
    ) throws -> [String] {
        guard let path else { throw Error.invalidProjectPath }
        let projectPath = Path(path)
        let xcodeproj = try XcodeProj(path: projectPath)
        let targets = xcodeproj.pbxproj.nativeTargets
        let targetNames = targets.compactMap { $0.name }
        return targetNames
    }

    /// Parses an Xcode project and returns a Target object.
    func parseXcodeProjectTarget(
        at path: String?,
        targetName: String?,
        root: String?,
        verbose: Bool
    ) throws -> Target {
        guard let path else { throw Error.invalidProjectPath }
        guard let targetName else { throw Error.invalidTargetName }
        guard let root else { throw Error.invalidRootPath }
        let projectPath = Path(path)
        let xcodeproj = try XcodeProj(path: projectPath)
        guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {  throw Error.invalidTargetName }
        let packages = target.packageProductDependencies?.map { $0.productName } ?? []
        let filePaths = try target.sourcesBuildPhase()?.files?.map { try $0.file?.fullPath(sourceRoot: root) ?? "" }.filter { $0.hasSuffix(".swift") } ?? []
        let targetDependencies = target.dependencies.compactMap { $0.target?.name }
        let dependencies = Set(packages + targetDependencies)
        if verbose {
            var message = "Target \(targetName) dependencies \(dependencies.count):\n"
            for dependency in Array(dependencies).sorted() {
                message += " - \(dependency)\n"
            }
            print(message)
        }
        return Target(
            name: targetName,
            dependencies: dependencies,
            swiftFiles: Set(
                filePaths
            )
        )
    }
}
