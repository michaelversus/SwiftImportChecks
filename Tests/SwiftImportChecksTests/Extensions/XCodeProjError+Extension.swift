//
//  XCodeProjError+Extension.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

import XcodeProj
import PathKit

extension XCodeProjError: @retroactive Equatable {
    public static func == (lhs: XCodeProjError, rhs: XCodeProjError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound(let lhsPath), .notFound(let rhsPath)):
            return lhsPath.string == rhsPath.string
        case (.pbxprojNotFound(let lhsPath), .pbxprojNotFound(let rhsPath)):
            return lhsPath.string == rhsPath.string
        case (.xcworkspaceNotFound(let lhsPath), .xcworkspaceNotFound(let rhsPath)):
            return lhsPath.string == rhsPath.string
        default:
            return false
        }

    }
}
