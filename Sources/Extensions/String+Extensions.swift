//
//  String+Extensions.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

extension String {
    /// An array of lines in this string, created by splitting on line breaks
    var lines: [String] {
        components(separatedBy: "\n")
    }

    /// BodyStripper removes all comments and most whitespace, but it doesn't collapse multiple
    /// repeating instances do line breaks. This method does that clean up work.
    func removingDuplicateLineBreaks() -> String {
        let strippedLines = self.lines
        let nonEmptyLines = strippedLines.filter { $0.isEmpty == false }
        return nonEmptyLines.joined(separator: "\n")
    }

    /// removes all comments and whitespace from the string and also suffixes that begin with a dot
    /// - returns: a string with all comments and whitespace removed
    func removingCommentsWhitespaceAndDotSuffix() -> String {
        let strippedLines = self.lines
            .filter { $0.isEmpty == false }
            .compactMap {
                $0.split(separator: ".").first
            }
            .map { $0.replacingOccurrences(of: "//.*", with: "", options: .regularExpression) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return strippedLines.joined(separator: "\n")

    }
}
