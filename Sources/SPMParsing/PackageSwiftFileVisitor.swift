//
//  PackageSwiftFileVisitor.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 9/5/25.
//


import SwiftSyntax

final class PackageSwiftFileVisitor: SyntaxVisitor {
    var packageName: String?
    var targets: [SwiftPackageTarget] = []
    var layers: [String: Int] = [:]

    override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        guard let leadingTrivia = node.leadingTrivia else { return .visitChildren }
        for piece in leadingTrivia {
            if case let .lineComment(comment) = piece {
                if comment.contains("swift-import-checks") {
                    let components = comment.components(separatedBy: ":")
                    if components.count > 2 {
                        let layerNumber = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        let targetName = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                        layers[targetName] = Int(layerNumber)
                    }
                }
            }
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard
            let identifier = node.calledExpression.as(IdentifierExprSyntax.self)?.identifier.text,
            identifier == "Package"
        else { return .visitChildren }
        packageName = node.argumentList.first(where: { $0.label?.text == "name" })?.expression.description.trimmingCharacters(in: .punctuationCharacters)
        let targetsArgument = node.argumentList.first(where: { $0.label?.text == "targets" })
        guard let targetsArray = targetsArgument?.expression.as(ArrayExprSyntax.self)?.elements else { return .visitChildren }
        
        for targetElement in targetsArray {
            guard
                let targetCall = targetElement.expression.as(FunctionCallExprSyntax.self),
                let targetName = targetCall.argumentList.first(where: { $0.label?.text == "name" })?.expression.description.trimmingCharacters(in: .punctuationCharacters)
            else { continue }

            let targetType: SwiftPackageFile.TargetType
            switch targetCall.calledExpression.description.trimmingCharacters(in: .whitespacesAndNewlines) {
            case ".executableTarget":
                targetType = .executable
            case ".testTarget":
                targetType = .test
            default:
                targetType = .regular
            }

            let dependenciesArray = targetCall.argumentList.first(where: { $0.label?.text == "dependencies" })?.expression.as(ArrayExprSyntax.self)?.elements
            let dependencies = dependenciesArray?.compactMap { element -> String? in
                if let stringLiteral = element.expression.as(StringLiteralExprSyntax.self) {
                    return stringLiteral.segments.description.trimmingCharacters(in: .punctuationCharacters)
                } else if let functionCall = element.expression.as(FunctionCallExprSyntax.self),
                          functionCall.calledExpression.description.contains(".product"),
                          let productName = functionCall.argumentList.first(where: { $0.label?.text == "name" })?.expression.as(StringLiteralExprSyntax.self)?.segments.description.trimmingCharacters(in: .punctuationCharacters) {
                    return productName
                } else if let functionCall = element.expression.as(FunctionCallExprSyntax.self),
                          functionCall.calledExpression.description.contains(".target"),
                          let targetName = functionCall.argumentList.first(where: { $0.label?.text == "name" })?.expression.as(StringLiteralExprSyntax.self)?.segments.description.trimmingCharacters(in: .punctuationCharacters) {
                    return targetName
                }
                return nil
            } ?? []
            let dependenciesSet = Set(dependencies)
            let target = SwiftPackageTarget(
                name: targetName,
                type: targetType,
                dependencies: dependenciesSet,
                duplicateDependencies: findDuplicateDependencies(dependencies),
                layerNumber: layers[targetName]
            )
            targets.append(target)
        }
        return .visitChildren
    }

    private func findDuplicateDependencies(_ dependencies: [String]) -> [String] {
        var seen = Set<String>()
        var duplicates = Set<String>()
        for item in dependencies {
            if !seen.insert(item).inserted {
                duplicates.insert(item)
            }
        }
        return Array(duplicates)
    }
}
