//
//  SwiftType.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation

/// One data type from our code, with a very loose definition of "type"
final class SwiftType: Node {
    /// All the data we want to be able to write out for debugging purposes
    private enum CodingKeys: CodingKey {
        case name, type, inheritance, comments, body, strippedBody
    }

    /// The list of "types" we support
    enum ObjectType: String {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    /// The name of the type, eg `ViewController`
    let name: String

    /// The underlying type, e.g. class or struct
    let type: ObjectType

    /// The inheritance clauses attached to this type, including protocol conformances
    let inheritance: [String]

    /// An array of comments that describe this type
    let comments: [Comment]

    /// The raw source code for this type
    let body: String

    /// The source code for this type, minus empty lines and comments
    let strippedBody: String

    /// Creates an instance of Type
    init(type: ObjectType, name: String, inheritance: [String], comments: [Comment], body: String, strippedBody: String) {
        self.type = type
        self.name = name
        self.inheritance = inheritance
        self.comments = comments
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.strippedBody = body.removingDuplicateLineBreaks()
    }

    /// Encodes the type, so we can produce debug output
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(inheritance, forKey: .inheritance)
        try container.encode(comments, forKey: .comments)
        try container.encode(body, forKey: .body)
        try container.encode(strippedBody, forKey: .strippedBody)
    }
}
