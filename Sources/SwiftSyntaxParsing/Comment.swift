//
//  Comment.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 22/4/25.
//

/// One comment, regular or documentation, from the code
struct Comment: Encodable {
    enum CommentType: String, Encodable {
        case regular, documentation
    }

    var type: CommentType
    var text: String
}
