//
//  XCSourceTextPosition.swift
//  XcodeEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

extension XCSourceTextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        lhs.line == rhs.line && lhs.column == rhs.column
    }

    var beginningOfLine: Self {
        Self(line: self.line, column: 0)
    }

    var endOfLineIncludingNewline: Self {
        // TODO: if the selection IS the last line, does this work/crash?

        Self(line: self.line + 1, column: 0)
    }
}
