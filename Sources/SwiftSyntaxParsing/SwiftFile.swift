//
//  SwiftFile.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation
import SwiftSyntaxParser

struct SwiftFile {
    /// The swift file URL
    let url: URL?
    /// The file visitor that scans the code
    var results: FileVisitor

    /// Creates an instance of the scanner from a file, then starts it walking through code
    init(url: URL) throws {
        self.url = url
        results = FileVisitor(viewMode: .fixedUp)

        let sourceFile = try SyntaxParser.parse(url)
        results.walk(sourceFile)
    }

    /// Writes this file's tree to a JSON string for testing
    func debugPrint() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(results.rootNode)
        let json = String(decoding: encoded, as: UTF8.self)
        return json
    }
}
