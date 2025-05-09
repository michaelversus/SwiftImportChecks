//
//  SwiftPackageFile.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//

struct SwiftPackageFile: Equatable {
    let name: String
    let targets: [SwiftPackageTarget]

    init(
        name: String,
        targets: [SwiftPackageTarget] = []
    ) {
        self.name = name
        self.targets = targets
    }
}

extension SwiftPackageFile {
    enum TargetType: String, Codable {
        case unknown
        case regular
        case test
        case executable

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = TargetType(rawValue: value) ?? .unknown
        }

        var intermediatePath: String {
            switch self {
            case .regular, .executable:
                return "/Sources/"
            case .test:
                return "/Tests/"
            case .unknown:
                return ""
            }
        }
    }
}
