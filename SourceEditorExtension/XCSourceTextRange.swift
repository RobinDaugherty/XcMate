//
//  XCSourceTextRange.swift
//  XcodeEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

extension XCSourceTextRange {
    var isInsertionPoint: Bool {
        start == end
    }

    var rangeOfEntireContainingLine: Self {
        Self(start: self.start.beginningOfLine, end: self.start.endOfLineIncludingNewline)
    }
}
