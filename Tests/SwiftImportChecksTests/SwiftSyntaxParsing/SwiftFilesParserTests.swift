//
//  SwiftFilesParserTests.swift
//  SwiftImportChecksTests
//

@testable import SwiftImportChecks
import Darwin
import Foundation
import Testing

@Suite("SwiftFilesParser Tests")
struct SwiftFilesParserTests {

    @Test("SwiftFile debugPrint encodes the visitor tree as JSON")
    func swiftFileDebugPrint() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("Sample.swift")
        try "enum E { case a }\n".write(to: url, atomically: true, encoding: .utf8)

        let file = try SwiftFile(url: url)
        let json = try file.debugPrint()
        #expect(json.contains("\"cases\""))
        #expect(json.contains("\"a\""))
    }

    @Test("parseSwiftFiles verbose echo uses target name when an Xcode target is set")
    func verboseEchoUsesTargetName() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("Only.swift")
        try "import Foundation\n".write(to: url, atomically: true, encoding: .utf8)

        let target = Target(
            name: "XcodeTarget",
            dependencies: [],
            swiftFiles: [fileSystemCanonicalPath(url)]
        )
        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: target,
            packageTargetName: nil,
            verbose: true,
            echo: { lines.append($0) }
        )
        _ = try parser.parseSwiftFiles(config: .default, globalExcludedPaths: [])

        #expect(lines.contains { $0.contains("XcodeTarget") && $0.contains("parsed files count: 1") })
    }

    @Test("parseSwiftFiles verbose echo falls back to unknown when target and package names are nil")
    func verboseEchoUnknownName() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("Loose.swift")
        try "import Foundation\n".write(to: url, atomically: true, encoding: .utf8)

        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: nil,
            packageTargetName: nil,
            verbose: true,
            echo: { lines.append($0) }
        )
        _ = try parser.parseSwiftFiles(config: .default, globalExcludedPaths: [])

        #expect(lines.contains { $0.contains("unknown") && $0.contains("parsed files count: 1") })
    }

    @Test("parseSwiftFiles uses packageTargetName when target is nil (verbose path)")
    func packageTargetNameAndVerboseEcho() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("Main.swift")
        try "import Foundation\n".write(to: url, atomically: true, encoding: .utf8)

        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: nil,
            packageTargetName: "MyPackage",
            verbose: true,
            echo: { lines.append($0) }
        )
        let config = Configuration.default
        _ = try parser.parseSwiftFiles(config: config, globalExcludedPaths: [])

        #expect(lines.contains { $0.contains("MyPackage") && $0.contains("linked files count: 1") })
        #expect(lines.contains { $0.contains("parsed files count: 1") })
    }

    @Test("findFiles skips Swift files under excluded config paths")
    func excludedPathsSkipFiles() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let visible = tmp.appendingPathComponent("Visible").appendingPathComponent("Vis.swift")
        try FileManager.default.createDirectory(at: visible.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "import Foundation\n".write(to: visible, atomically: true, encoding: .utf8)

        let hiddenDir = tmp.appendingPathComponent("SecretDir")
        try FileManager.default.createDirectory(at: hiddenDir, withIntermediateDirectories: true)
        let hidden = hiddenDir.appendingPathComponent("Hid.swift")
        try "import Foundation\n".write(to: hidden, atomically: true, encoding: .utf8)

        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            verbose: false,
            echo: { _ in }
        )
        let config = Configuration(excluded: ["SecretDir"])
        let results = try parser.parseSwiftFiles(config: config, globalExcludedPaths: [])

        #expect(results.files.count == 1)
        #expect(results.files.first?.url.lastPathComponent == "Vis.swift")
    }

    @Test("findFiles with Xcode target keeps only paths listed on the target")
    func targetFiltersSwiftFiles() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let a = tmp.appendingPathComponent("A.swift")
        let b = tmp.appendingPathComponent("B.swift")
        try "import Foundation\n".write(to: a, atomically: true, encoding: .utf8)
        try "import Foundation\n".write(to: b, atomically: true, encoding: .utf8)

        let target = Target(
            name: "T",
            dependencies: [],
            swiftFiles: [fileSystemCanonicalPath(a)]
        )
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: target,
            verbose: false,
            echo: { _ in }
        )
        let results = try parser.parseSwiftFiles(config: .default, globalExcludedPaths: [])

        #expect(results.files.count == 1)
        #expect(results.files.first?.url.lastPathComponent == "A.swift")
    }

    @Test("parseSwiftFiles drops Swift sources that cannot be read or parsed")
    func unreadableSwiftFileSkipped() throws {
        let tmp = try makeTempRoot()
        let good = tmp.appendingPathComponent("Good.swift")
        let bad = tmp.appendingPathComponent("Bad.swift")
        try "struct OK {}\n".write(to: good, atomically: true, encoding: .utf8)
        try "struct X {}\n".write(to: bad, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: bad.path)

        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: bad.path)
            try? FileManager.default.removeItem(at: tmp)
        }

        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            verbose: false,
            echo: { _ in }
        )
        let results = try parser.parseSwiftFiles(config: .default, globalExcludedPaths: [])

        #expect(results.files.count == 1)
        #expect(results.files.first?.url.lastPathComponent == "Good.swift")
    }

    @Test("forbidden import echo uses dash when target and package names are nil")
    func forbiddenImportsEchoDashWhenUnnamed() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("Unnamed.swift")
        try "import BannedOnlyHere\n".write(to: url, atomically: true, encoding: .utf8)

        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: nil,
            packageTargetName: nil,
            verbose: false,
            echo: { lines.append($0) }
        )
        let config = Configuration(forbiddenImports: ["BannedOnlyHere"])

        #expect(throws: ConfigError.forbiddenImportsFound) {
            try parser.parseSwiftFiles(config: config, globalExcludedPaths: [])
        }
        #expect(lines.contains { $0.contains("🚫 Target: - contains forbidden import") })
    }

    @Test("collate throws when a forbidden import appears")
    func forbiddenImportsThrow() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("F.swift")
        try "import NotAllowed\n".write(to: url, atomically: true, encoding: .utf8)

        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: nil,
            packageTargetName: "Pkg",
            verbose: false,
            echo: { lines.append($0) }
        )
        let config = Configuration(forbiddenImports: ["NotAllowed"])

        #expect(throws: ConfigError.forbiddenImportsFound) {
            try parser.parseSwiftFiles(config: config, globalExcludedPaths: [])
        }
        #expect(lines.contains { $0.contains("🚫") && $0.contains("NotAllowed") })
    }

    @Test("collate echoes target name when forbidden import hits an Xcode target")
    func forbiddenImportsEchoTargetName() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("F.swift")
        try "import BadMod\n".write(to: url, atomically: true, encoding: .utf8)

        let target = Target(name: "AppTarget", dependencies: [], swiftFiles: [fileSystemCanonicalPath(url)])
        var lines = [String]()
        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            target: target,
            packageTargetName: nil,
            verbose: false,
            echo: { lines.append($0) }
        )
        let config = Configuration(forbiddenImports: ["BadMod"])

        #expect(throws: ConfigError.forbiddenImportsFound) {
            try parser.parseSwiftFiles(config: config, globalExcludedPaths: [])
        }
        #expect(lines.contains { $0.contains("AppTarget") && $0.contains("BadMod") })
    }

    @Test("SwiftFilesParser init uses default echo when omitted")
    func defaultPrintEcho() throws {
        let tmp = try makeTempRoot()
        defer { try? FileManager.default.removeItem(at: tmp) }
        let url = tmp.appendingPathComponent("One.swift")
        try "import Foundation\n".write(to: url, atomically: true, encoding: .utf8)

        let parser = SwiftFilesParser(
            rootURL: URL(fileURLWithPath: fileSystemCanonicalPath(tmp), isDirectory: true),
            verbose: false
        )
        _ = try parser.parseSwiftFiles(config: .default, globalExcludedPaths: [])
    }

    private func makeTempRoot() throws -> URL {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftFilesParserTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.resolvingSymlinksInPath()
    }

    /// Matches path strings from `FileManager.enumerator` (e.g. `/private/var/...` vs `URL.path`’s `/var/...`).
    private func fileSystemCanonicalPath(_ url: URL) -> String {
        url.path.withCString { p in
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX))
            defer { buffer.deallocate() }
            guard let resolved = realpath(p, buffer) else { return url.path }
            return String(cString: resolved)
        }
    }
}
