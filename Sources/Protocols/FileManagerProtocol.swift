//
//  FileManagerProtocol.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 26/4/25.
//

import Foundation

protocol FileManagerProtocol {
    var currentDirectoryPath: String { get }
    func fileExists(atPath path: String) -> Bool
}

extension FileManager: FileManagerProtocol {}
