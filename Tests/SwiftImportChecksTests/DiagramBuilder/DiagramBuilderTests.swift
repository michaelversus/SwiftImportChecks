//
//  DiagramBuilderTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 13/5/25.
//

import Testing
import Foundation
@testable import SwiftImportChecks

@Suite("DiagramBuilder Tests")
struct DiagramBuilderTests {
    var packages: [SwiftPackageFile] = []

    @Test("test append function")
    func testAppend() async throws {
        // Given
        var messages: [String] = []
        let sut = makeSUT { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(name: "TestPackage")

        // When
        sut.append(package: package)

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given nil diagrams config")
    func testGenerateDiagramGivenNilDiagramsConfigSkips() async throws {
        // Given
        var messages: [String] = []
        let sut = makeSUT { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(name: "TestPackage")

        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given nil diagrams.regular config")
    func testGenerateDiagramGivenNilDiagramsRegularConfigSkips() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(regular: nil)
        )
        var messages: [String] = []
        let sut = makeSUT(configs: configs) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(name: "TestPackage")


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given empty diagrams.regular.layers config")
    func testGenerateDiagramGivenEmptyDiagramsRegularLayersConfigSkips() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(
                regular: DiagramConfiguration(layers: [])
            )
        )
        var messages: [String] = []
        let sut = makeSUT(configs: configs) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(name: "TestPackage")


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given valid diagrams.regular.layers config and invalid package skips the process")
    func testGenerateDiagramGivenValidDiagramsRegularLayersConfigSkips() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(
                regular: DiagramConfiguration(
                    layers: ["Foundation", "Framework"]
                )
            )
        )
        var messages: [String] = []
        let sut = makeSUT(configs: configs) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(name: "TestPackage")


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given valid diagrams.regular.layers config and not regular package skips the process")
    func testGenerateDiagramGivenValidConfigAndNotRegularPackageSkips() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(
                regular: DiagramConfiguration(
                    layers: ["Foundation", "Framework"]
                )
            )
        )
        var messages: [String] = []
        let sut = makeSUT(configs: configs) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(
            name: "TestPackage",
            targets: [
                SwiftPackageTarget(
                    name: "TestTarget",
                    type: .test,
                    dependencies: [],
                    duplicateDependencies: [],
                    layerNumber: nil
                )
            ]
        )


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given valid diagrams.regular.layers config and regular package with nil layerNumber skips the process")
    func testGenerateDiagramGivenValidConfigAndRegularPackageWithNilLayerNumberSkips() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(
                regular: DiagramConfiguration(
                    layers: ["Foundation", "Framework"]
                )
            )
        )
        var messages: [String] = []
        let sut = makeSUT(configs: configs) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(
            name: "TestPackage",
            targets: [
                SwiftPackageTarget(
                    name: "TestTarget",
                    type: .regular,
                    dependencies: [],
                    duplicateDependencies: [],
                    layerNumber: nil
                )
            ]
        )


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == [])
    }

    @Test("test generateDiagram function given valid diagrams.regular.layers config and regular package with valid layerNumber success")
    func testGenerateDiagramGivenValidConfigAndRegularPackageWithValidLayerNumberSuccess() async throws {
        // Given
        let configs = Configurations(
            diagrams: DiagramsConfiguration(
                regular: DiagramConfiguration(
                    layers: ["Foundation", "Framework"]
                )
            )
        )
        var messages: [String] = []
        let sut = makeSUT(
            packagesPath: "./",
            configs: configs
        ) { message in
            messages.append(message)
        }
        let package = SwiftPackageFile(
            name: "TestPackage",
            targets: [
                SwiftPackageTarget(
                    name: "TestTarget",
                    type: .regular,
                    dependencies: [],
                    duplicateDependencies: [],
                    layerNumber: 0
                )
            ]
        )


        // When
        sut.append(package: package)
        sut.generateDiagram()

        // Then
        #expect(messages == ["Packages Diagram generated at .//packages.html"])
    }

}

extension DiagramBuilderTests {
    private func makeSUT(
        packagesPath: String = "packagesPath",
        configs: Configurations = .default,
        echo: @escaping (String) -> Void
    ) -> DiagramBuilder {
        DiagramBuilder(
            packagesPath: packagesPath,
            packages: packages,
            configs: configs,
            echo: echo
        )
    }
}

private extension URL {
    enum Mock {
        static let exampleXcodeProject = Bundle.module.url(
            forResource: "Example/SwiftTestFile",
            withExtension: "swift"
        )?
        .deletingPathExtension()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    }
}
