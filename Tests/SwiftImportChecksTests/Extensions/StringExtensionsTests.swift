//
//  StringExtensionsTests.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 28/4/25.
//

@testable import SwiftImportChecks
import Testing

@Suite("StringExtensions Tests")
struct StringExtensionsTests {

    @Test("test string extension for lines")
    func lines() {
        // Given
        let string = """
        Line 1
        Line 2
        Line 3
        """
        let expectedLines = ["Line 1", "Line 2", "Line 3"]

        // When
        let lines = string.lines

        // Then
        #expect(lines == expectedLines)
    }

    @Test("test removingDuplicateLineBreaks")
    func removingDuplicateLineBreaks() {
        // Given
        let string = """
        Line 1
        Line 2
        
        Line 3
        """

        let expectedString = """
        Line 1
        Line 2
        Line 3
        """

        // When
        let result = string.removingDuplicateLineBreaks()

        // Then
        #expect(result == expectedString)
    }

    @Test("test removingCommentsWhitespaceAndDotSuffix given comments")
    func removingCommentsWhitespaceAndDotSuffixGivenComments() {
        // Given
        let string = """
        import SomeModule // This is a comment
        """

        let expectedString = "import SomeModule"

        // When
        let result = string.removingCommentsWhitespaceAndDotSuffix()

        // Then
        #expect(result == expectedString)
    }

    @Test("test removingCommentsWhitespaceAndDotSuffix given dotSyntax")
    func removingCommentsWhitespaceAndDotSuffixGivenDotSyntax() {
        // Given
        let string = """
        import SomeModule.SomeClass
        """

        let expectedString = "import SomeModule"

        // When
        let result = string.removingCommentsWhitespaceAndDotSuffix()

        // Then
        #expect(result == expectedString)
    }

    @Test("test removingCommentsWhitespaceAndDotSuffix given .syntax and comments")
    func removingCommentsWhitespaceAndDotSuffixGivenDotSyntaxAndComments() {
        // Given
        let string = """
        import SomeModule.SomeClass // comment
        """

        let expectedString = "import SomeModule"

        // When
        let result = string.removingCommentsWhitespaceAndDotSuffix()

        // Then
        #expect(result == expectedString)
    }
}
