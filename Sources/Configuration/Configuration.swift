//
//  Configuration.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

import Foundation
import Yams

struct Configurations: Codable, Equatable {
    let configurations: [String: Configuration]
    let excludedPaths: [String]
    let excludedTargets: [String]
    let excludedPackages: [String]
    let diagrams: DiagramsConfiguration?

    init(
        configurations: [String: Configuration] = [:],
        excludedTargets: [String] = [],
        excludedPaths: [String] = [],
        excludedPackages: [String] = [],
        diagrams: DiagramsConfiguration? = nil
    ) {
        self.configurations = configurations
        self.excludedTargets = excludedTargets
        self.excludedPaths = excludedPaths
        self.excludedPackages = excludedPackages
        self.diagrams = diagrams
    }

    private enum CodingKeys: CodingKey {
        case configurations
        case excludedPaths
        case excludedPackages
        case excludedTargets
        case diagrams
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let configurations = try? container.decode([String: Configuration].self, forKey: .configurations)
        let excludedTargets = try? container.decode([String].self, forKey: .excludedTargets)
        let excludedPackages = try? container.decode([String].self, forKey: .excludedPackages)
        let excludedPaths = try? container.decode([String].self, forKey: .excludedPaths)
        self.diagrams = try? container.decode(DiagramsConfiguration.self, forKey: .diagrams)
        self.excludedTargets = excludedTargets ?? []
        self.excludedPackages = excludedPackages ?? []
        self.excludedPaths = excludedPaths ?? []
        self.configurations = configurations ?? [:]
    }
}

extension Configurations {
    static let `default`: Configurations = .init(
        configurations: [:]
    )

    static func parse(_ path: String) throws -> Configurations {
        let url = URL(fileURLWithPath: path)
        return try .parse(url)
    }

    static func parse(_ url: URL) throws -> Configurations {
        let decoder = YAMLDecoder()
        let data = try String(contentsOf: url)
        return try decoder.decode(Self.self, from: data)
    }
}

struct Configuration: Codable, Equatable {
    private let excluded: [String]
    let excludedImports: [String]
    let forbiddenImports: [String]

    init(
        excluded: [String] = [],
        excludedImports: [String] = [],
        forbiddenImports: [String] = []
    ) {
        self.excluded = excluded
        self.excludedImports = excludedImports
        self.forbiddenImports = forbiddenImports
    }

    private enum CodingKeys: CodingKey {
        case excluded
        case excludedImports
        case forbiddenImports
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let excluded = try? values.decode([String].self, forKey: .excluded)
        let excludedImports = try? values.decode([String].self, forKey: .excludedImports)
        let forbiddenImports = try? values.decode([String].self, forKey: .forbiddenImports)
        self.excluded = excluded ?? []
        self.excludedImports = excludedImports ?? []
        self.forbiddenImports = forbiddenImports ?? []
    }

    func excludedPath(path: String) -> [String] {
        excluded.map {
            "\(path)/\($0)"
        }
    }
}

extension Configuration {
    static let `default` = Configuration()
}

struct DiagramsConfiguration: Codable, Equatable {
    let regular: DiagramConfiguration?
    let test: DiagramConfiguration?

    private enum CodingKeys: CodingKey {
        case regular
        case test
    }

    init(
        regular: DiagramConfiguration? = nil,
        test: DiagramConfiguration? = nil
    ) {
        self.regular = regular
        self.test = test
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.regular = try? values.decode(DiagramConfiguration.self, forKey: .regular)
        self.test = try? values.decode(DiagramConfiguration.self, forKey: .test)
    }
}

struct DiagramConfiguration: Codable, Equatable {
    let layers: [String]

    private enum CodingKeys: CodingKey {
        case layers
    }

    init(layers: [String] = []) {
        self.layers = layers
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let layers = try? values.decode([String].self, forKey: .layers)
        self.layers = layers ?? []
    }
}
