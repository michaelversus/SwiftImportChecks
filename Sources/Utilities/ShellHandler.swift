//
//  ShellHandler.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//
import Foundation

enum ShellHandler {
    static func shell(_ command: String) throws -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["bash", "-c", command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}

enum CommandFlowError: Error, CustomStringConvertible {
    case shellOutputNil

    var description: String {
        switch self {
        case .shellOutputNil:
            return "❌ Shell output is nil"
        }
    }
}
