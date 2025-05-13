//
//  MockDiagramBuilder.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 13/5/25.
//

@testable import SwiftImportChecks

final class MockDiagramBuilder: DiagramBuilderProtocol {
    var actions: [Action] = []

    enum Action: Equatable {
        case append(package: SwiftPackageFile)
        case generateDiagram
    }

    func append(package: SwiftPackageFile) {
        actions.append(.append(package: package))
    }
    
    func generateDiagram() {
        actions.append(.generateDiagram)
    }
}
