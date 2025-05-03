//
//  URL+Extensions.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 29/4/25.
//

import Foundation

extension URL {
    func containsOneOf(paths: [String]) -> Bool {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let pathComponents = urlComponents?.path.components(separatedBy: "/") ?? []
        let pathsSet = Set(paths)
        for component in pathComponents {
            if pathsSet.contains(component) {
                return true
            }
        }
        return false
    }
}
