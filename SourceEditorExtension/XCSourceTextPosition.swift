//
//  XCSourceTextPosition.swift
//  XcodeEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

extension XCSourceTextPosition {
    var beginningOfLine: Self {
        Self(line: self.line, column: 0)
    }
}

extension XCSourceTextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        lhs.line == rhs.line && lhs.column == rhs.column
    }
}

extension XCSourceTextPosition: Comparable {
    public static func < (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        lhs.line < rhs.line ||
        (lhs.line == rhs.line && lhs.column < rhs.column)
    }
}
