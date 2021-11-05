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
}

extension XCSourceTextRange: Comparable {
    public static func < (lhs: XCSourceTextRange, rhs: XCSourceTextRange) -> Bool {
        // This makes the assumption that any array of selections is non-overlapping
        lhs.start < rhs.start
    }
}
