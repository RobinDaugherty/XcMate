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

        for selectionIndex in (0..<buffer.selections.count) {
            let originalRange: XCSourceTextRange = (buffer.selections[selectionIndex] as! XCSourceTextRange).copy() as! XCSourceTextRange
            let effectiveRange: XCSourceTextRange

            if originalRange.isInsertionPoint, originalRange.start.line < buffer.lines.count {
                // Insertion point alone implies "this entire line"
                effectiveRange = XCSourceTextRange(
                    start: XCSourceTextPosition(line: originalRange.start.line, column: 0),
                    end: XCSourceTextPosition(line: originalRange.start.line + 1, column: 0)
                )
            } else {
                effectiveRange = originalRange
            }

            let startPosition = effectiveRange.start
            let lineToModify = startPosition.line

            let duplicatingContent = buffer.string(in: effectiveRange)

            // TODO: Would this just be the same as ((end.line - start.line) - 1)?
            let additionalLineCount = duplicatingContent.reduce(into: 0) { result, character in
                if character == "\n" {
                    result += 1
                }
            }

            var lineContent = startPosition.line < buffer.lines.count ? buffer.lines[startPosition.line] as? String ?? "" : ""

            // Insert the new content at the current position of the seelection
            let insertionIndex = lineContent.index(lineContent.startIndex, offsetBy: startPosition.column)
            lineContent.insert(contentsOf: duplicatingContent, at: insertionIndex)

            if additionalLineCount > 0 {
                // We must insert new lines here to ensure the extension doesn't crash if it tries to add more lines than there are in the buffer. Seriously.
                let newIndexes = IndexSet((0..<additionalLineCount).map({ $0 + lineToModify }))
                buffer.lines.insert((0..<additionalLineCount).map({ _ in "" }), at: newIndexes)

                // Don't allow the selection to expand as a result of the new lines.
                buffer.selections[selectionIndex] = originalRange
            }

            // Modify the buffer content to include the duplication
            buffer.lines[lineToModify] = lineContent

            let columnOffset = duplicatingContent.count

            if additionalLineCount > 0 {
                // If new lines were added, this selection got expanded automatically to include the new lines.
                // However, we don't want that, we only want the selection to remain on the original string.
                buffer.selections[selectionIndex] = originalRange.movedBy(lines: additionalLineCount)
            } else if columnOffset > 0 {
                // But if no new lines were added, we need to move all selections on this line at or after the insertion so they remain on the same strings as before.
                for modifyingIndex in (0..<buffer.selections.count) {
                    let modifyingSelectionRange = buffer.selections[modifyingIndex] as! XCSourceTextRange
                    // Don't modify selections that are on a different line or before this selection on the same line
                    guard modifyingSelectionRange.start.line == originalRange.start.line, modifyingSelectionRange.start >= originalRange.start else {
                        continue
                    }

                    buffer.selections[modifyingIndex] = modifyingSelectionRange.movedBy(columns: columnOffset)
                }
            }
        }

        completionHandler(nil)
    }
}
