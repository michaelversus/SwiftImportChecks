//
//  SwiftPackageFileTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

import Foundation
import Testing
@testable import SwiftImportChecks

@Suite("SwiftPackageFile Tests")
struct SwiftPackageFileTests {

    @Test("test SwiftPackageFile decoding given empty data")
    func targetDecodingGivenEmptyData() throws {
        // Given
        let data: Data = SwiftPackageFile.emptyMockData()

        // When
        let package = try JSONDecoder().decode(SwiftPackageFile.self, from: data)

        // Then
        #expect(package == .emptyMock())
    }

    @Test("test SwiftPackageFile decoding given valid data")
    func targetDecodingGivenValidData() throws {
        // Given
        let data: Data = SwiftPackageFile.mockData()

        // When
        let package = try JSONDecoder().decode(SwiftPackageFile.self, from: data)

        // Then
        #expect(package == .mock())
    }

    @Test("test SwiftPackageFile.Target.Dependency name given only target array")
    func nameGivenOnlyTarget() throws {
        // Given
        let targetDependency = SwiftPackageFile.Target.Dependency(
            target: [
                "MockTarget",
                "MockPackage",
                nil,
                nil
            ]
        )

        // When
        let result = targetDependency.name()

        // Then
        #expect(result == "MockTarget")
    }

    @Test("test SwiftPackageFile.Target.Dependency name given nilimput for all arrays")
    func nameGivenNilInput() throws {
        // Given
        let targetDependency = SwiftPackageFile.Target.Dependency()

        // When
        let result = targetDependency.name()

        // Then
        #expect(result == nil)
    }

    @Test("test SwiftPackageFile.Target.Dependency name given target array and byName array returns byName")
    func nameGivenTargetAndByName() throws {
        // Given
        let targetDependency = SwiftPackageFile.Target.Dependency(
            byName: [
                "MockByName",
                "MockPackage",
                nil,
                nil
            ],
            target: [
                "MockTarget",
                "MockPackage",
                nil,
                nil
            ]
        )

        // When
        let result = targetDependency.name()

        // Then
        #expect(result == "MockByName")
    }

    @Test("test SwiftPackageFile.Target.Dependency name given all returns product")
    func nameGivenAll() throws {
        // Given
        let targetDependency = SwiftPackageFile.Target.Dependency(
            product: [
                "MockProduct",
                "MockPackage",
                nil,
                nil
            ],
            byName: [
                "MockByName",
                "MockPackage",
                nil,
                nil
            ],
            target: [
                "MockTarget",
                "MockPackage",
                nil,
                nil
            ]
        )

        // When
        let result = targetDependency.name()

        // Then
        #expect(result == "MockProduct")
    }

    @Test(
        "test SwiftPackage.TargetType intermediatePath given target types",
        arguments: [
            (SwiftPackageFile.TargetType.unknown, ""),
            (SwiftPackageFile.TargetType.regular, "/Sources/"),
            (SwiftPackageFile.TargetType.test, "/Tests/"),
            (SwiftPackageFile.TargetType.executable, "/Sources/")
        ]
    )
    func intermediatePath(type: SwiftPackageFile.TargetType, result: String) throws {
        // Given, When
        let intermediatePath = type.intermediatePath

        // Then
        #expect(intermediatePath == result)
    }
}

extension SwiftPackageFile.Target {
    static func emptyMockData() -> Data {
        Data(SwiftPackageFile.Target.emptyMockString().utf8)
    }

    static func emptyMockString() -> String {
        """
        {
            "name": "MockTarget",
            "type": "someTargetType",
            "dependencies": []
        }
        """
    }

    static func emptyMock() -> SwiftPackageFile.Target {
        SwiftPackageFile.Target(
            name: "MockTarget",
            type: .unknown,
            dependencies: []
        )
    }

    static func mockData() -> Data {
        Data(SwiftPackageFile.Target.mockString().utf8)
    }

    static func mockString() -> String {
        """
        {
            "name": "MockTarget",
            "type": "regular",
            "dependencies": [
                {
                    "product": [
                        "MockProduct",
                        "MockPackage",
                        null,
                        null
                    ]
                },
                {
                    "target": [
                        "MockTarget",
                        "MockPackage",
                        null,
                        null
                    ]
                },
                {
                    "byName": [
                        "MockByName",
                        "MockPackage",
                        null,
                        null
                    ]
                }
            ]
        }
        """
    }

    static func mock() -> SwiftPackageFile.Target {
        SwiftPackageFile.Target(
            name: "MockTarget",
            type: .regular,
            dependencies: [
                SwiftPackageFile.Target.Dependency(
                    product: [
                        "MockProduct",
                        "MockPackage",
                        nil,
                        nil
                    ]
                ),
                SwiftPackageFile.Target.Dependency(
                    target: [
                        "MockTarget",
                        "MockPackage",
                        nil,
                        nil
                    ]
                ),
                SwiftPackageFile.Target.Dependency(
                    byName: [
                        "MockByName",
                        "MockPackage",
                        nil,
                        nil
                    ]
                )
            ]
        )
    }
}

extension SwiftPackageFile {
    static func emptyMockData() -> Data {
        Data(SwiftPackageFile.emptyMockString().utf8)
    }

    static func emptyMockString() -> String {
        """
        {
            "name": "MockPackage",
            "targets": [ \(SwiftPackageFile.Target.emptyMockString())
            ]
        }
        """
    }

    static func emptyMock() -> SwiftPackageFile {
        SwiftPackageFile(
            name: "MockPackage",
            targets: [.emptyMock()]
        )
    }

    static func mockData() -> Data {
        Data(SwiftPackageFile.mockString().utf8)
    }

    static func mockString() -> String {
        """
        {
            "name": "MockPackage",
            "targets": [ \(SwiftPackageFile.Target.mockString())
            ]
        }
        """
    }

    static func mock() -> SwiftPackageFile {
        SwiftPackageFile(
            name: "MockPackage",
            targets: [.mock()]
        )
    }
}
