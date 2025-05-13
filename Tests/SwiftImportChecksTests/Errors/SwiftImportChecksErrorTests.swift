//
//  SwiftImportChecksErrorTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 13/5/25.
//

@testable import SwiftImportChecks
import Testing

@Suite("SwiftImportChecksError Tests")
struct SwiftImportChecksErrorTests {
    @Test("test error description given invalidType error")
    func testErrorDescriptionGivenInvalidTypeError() {
        // Given
        let error = SwiftImportChecksError.invalidType

        // When, Then
        #expect(error.description == "❌ Invalid type provided.")
    }
}
