//
//  FileManagerMock.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

@testable import SwiftImportChecks

final class FileManagerMock: FileManagerProtocol {
    var currentDirectoryPath: String = ""
    var actions: [Action] = []
    var fileExistsReturnValue: Bool = false
    /// Path-specific overrides. If a path is in this dict, that value is used; otherwise fileExistsReturnValue.
    var fileExistsPaths: [String: Bool] = [:]

    enum Action {
        case fileExists(atPath: String)
    }

    init(
        currentDirectoryPath: String = "",
        fileExistsReturnValue: Bool = false,
        fileExistsPaths: [String: Bool] = [:]
    ) {
        self.currentDirectoryPath = currentDirectoryPath
        self.fileExistsReturnValue = fileExistsReturnValue
        self.fileExistsPaths = fileExistsPaths
    }

    func fileExists(atPath path: String) -> Bool {
        actions.append(.fileExists(atPath: path))
        return fileExistsPaths[path] ?? fileExistsReturnValue
    }
    
    
}
