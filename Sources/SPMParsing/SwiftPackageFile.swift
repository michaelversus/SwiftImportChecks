//
//  SwiftPackageFile.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 25/4/25.
//

struct SwiftPackageFile: Decodable, Equatable {
    let name: String
    let targets: [Target]

    enum CodingKeys: CodingKey {
        case name
        case targets
    }

    init(
        name: String,
        targets: [SwiftPackageFile.Target] = []
    ) {
        self.name = name
        self.targets = targets
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let targets = try? container.decode([SwiftPackageFile.Target].self, forKey: .targets)
        self.targets = targets ?? []
    }
}

extension SwiftPackageFile {
    struct Target: Decodable, Equatable {
        let name: String
        let type: TargetType
        let dependencies: [Dependency]

        enum CodingKeys: CodingKey {
            case name
            case type
            case dependencies
        }

        init(
            name: String,
            type: TargetType = .unknown,
            dependencies: [Dependency] = []
        ) {
            self.name = name
            self.type = type
            self.dependencies = dependencies
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SwiftPackageFile.Target.CodingKeys> = try decoder.container(keyedBy: SwiftPackageFile.Target.CodingKeys.self)
            self.name = try container.decode(String.self, forKey: SwiftPackageFile.Target.CodingKeys.name)
            let type = try? container.decode(SwiftPackageFile.TargetType.self, forKey: SwiftPackageFile.Target.CodingKeys.type)
            let dependencies = try? container.decode([SwiftPackageFile.Target.Dependency].self, forKey: SwiftPackageFile.Target.CodingKeys.dependencies)
            self.type = type ?? .unknown
            self.dependencies = dependencies ?? []
        }
    }
}

extension SwiftPackageFile.Target {
    struct Dependency: Decodable, Equatable {
        let product: [String?]?
        let byName: [String?]?
        let target: [String?]?

        init(
            product: [String?]? = nil,
            byName: [String?]? = nil,
            target: [String?]? = nil
        ) {
            self.product = product
            self.byName = byName
            self.target = target
        }

        func name() -> String? {
            let firstProduct = product?.compactMap { $0 }.first
            let firstByName = byName?.compactMap { $0 }.first
            let firstTarget = target?.compactMap { $0 }.first
            return firstProduct ?? firstByName ?? firstTarget
        }
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
