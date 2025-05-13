//
//  SwiftTestFile.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

import Foundation
import SwiftImportChecks
import PathKit

enum SwiftTestFile {}

// some comment

struct SomeStruct {
    let property: String
}

final class SomeClass {
    static let property: String = "c"

    init() {}

    func someMethod() {}

    static func someStaticMethod() {}
}
