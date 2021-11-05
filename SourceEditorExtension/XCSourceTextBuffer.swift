//
//  XCSourceTextBuffer.swift
//  XcodeEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

extension XCSourceTextBuffer {
    func string(in range: XCSourceTextRange) -> String {
        let lines: [String] = (range.start.line...range.end.line).map { lineNumber -> String in
            let line = self.lines[lineNumber] as! String

            let startIndex: String.Index
            let endIndex: String.Index

            if lineNumber != range.start.line, lineNumber != range.end.line {
                return line
            }

            if lineNumber == range.start.line, lineNumber == range.end.line {
                // If the entire range is on one line, return the selected part of the line
                startIndex = line.index(line.startIndex, offsetBy: range.start.column)
                endIndex = line.index(line.startIndex, offsetBy: range.end.column)
            } else if lineNumber == range.start.line {
                // If the range starts on the current line, return the end of the current line
                startIndex = line.index(line.startIndex, offsetBy: range.start.column)
                endIndex = line.endIndex
            } else { // Implying lineNumber == range.end.line
                // If the range ends on the current line, return the beginning of the current line
                startIndex = line.startIndex
                endIndex = line.index(line.startIndex, offsetBy: range.end.column)
            }

            return String(line[startIndex..<endIndex])
        }

        return lines.joined(separator: "\n")
    }
}
