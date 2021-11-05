//
//  DuplicateSelectionCommand.swift
//  XcodeEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

class DuplicateSelectionCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let buffer = invocation.buffer

        // Find the selections
        let selections: [XCSourceTextRange] = buffer.selections.compactMap({ selectedRange in
            guard let selectedRange = selectedRange as? XCSourceTextRange else { return nil }

            if selectedRange.isInsertionPoint, selectedRange.start.line < buffer.lines.count {
                // Insertion point implies "this entire line"
                let lineContent = buffer.lines[selectedRange.start.line] as? String ?? ""
                return XCSourceTextRange(
                    start: XCSourceTextPosition(line: selectedRange.start.line, column: 0),
                    end: XCSourceTextPosition(line: selectedRange.start.line, column: lineContent.count)
                )
            } else {
                return selectedRange
            }
        }).sorted()

        // Since each line modification might be inserting additional lines, we'll need to keep track of the changed line count before each insertion.
        let beginningLineCount: Int = buffer.lines.count

        // TODO: for each selection that starts on the same line, perform them as a group and modify the line once

        selections.forEach { originalRange in
            let originalStartPosition = originalRange.start

            // Since we're performing these selections from the top down, we can assume any additional lines are above the current selection.
            let lineOffset = (buffer.lines.count - beginningLineCount)
            let lineToModify = originalStartPosition.line + lineOffset

            let startPosition = XCSourceTextPosition(line: lineToModify, column: originalStartPosition.column)

            let range = XCSourceTextRange(start: startPosition, end: XCSourceTextPosition(line: originalRange.end.line + lineOffset, column: originalRange.end.column))

            let duplicatingContent = buffer.string(in: range)

            let newLinesToBeAdded = duplicatingContent.reduce(into: 0) { result, character in
                if character == "\n" {
                    result += 1
                }
            }

            // Insert the new content right before each selection
            // If the selection is the last "line" of the file, subscripting it will crash.
            var lineContent = startPosition.line < buffer.lines.count ? buffer.lines[startPosition.line] as? String ?? "" : ""

            let insertionIndex = lineContent.index(lineContent.startIndex, offsetBy: startPosition.column)
            lineContent.insert(contentsOf: duplicatingContent, at: insertionIndex)

            // We must insert new lines here to ensure the extension doesn't crash if it tries to add more lines than there are in the buffer. Seriously.
            if newLinesToBeAdded > 0 {
                let newIndexes = IndexSet((0..<newLinesToBeAdded).map({ $0 + lineToModify }))
                buffer.lines.insert((0..<newLinesToBeAdded).map({ _ in "\n" }), at: newIndexes)
            }

            buffer.lines[lineToModify] = lineContent
        }

        completionHandler(nil)
    }
}
