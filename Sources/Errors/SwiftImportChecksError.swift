//
//  SwiftImportChecksError.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 30/4/25.
//

enum SwiftImportChecksError: Error, CustomStringConvertible, Equatable {
    case invalidType

    var description: String {
        switch self {
        case .invalidType:
            return "❌ Invalid type provided."
        }
    }
}
