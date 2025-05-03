//
//  Node.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation

class Node: Encodable {
    /// The keys we need to write for debug output
    private enum CodingKeys: CodingKey {
        case cases, functions, types, variables
    }

    /// The parent of this node, so we can navigate back up the tree
    weak var parent: Node?

    /// All the variables defined by this node
    var variables = [String]()

    /// All the types defined inside this node
    var types = [SwiftType]()

    /// All the methods defined inside this node
    var functions = [SwiftFunction]()

    /// All the enum cases defined inside this node
    var cases = [String]()
}
