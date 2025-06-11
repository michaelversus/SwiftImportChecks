//
//  SwiftPackageTarget.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//

struct SwiftPackageTarget: Equatable {
    let name: String
    let type: SwiftPackageFile.TargetType
    let dependencies: Set<String>
    let duplicateDependencies: [String]
    let layerNumber: Int?
}
