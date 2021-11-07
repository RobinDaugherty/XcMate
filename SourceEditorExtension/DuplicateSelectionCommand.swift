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

        // let newIndexes = IndexSet((0..<newLinesToBeAdded).map({ $0 + lineToModify }))
        // buffer.lines.insert((0..<newLinesToBeAdded).map({ _ in "\n" }), at: newIndexes)
        // return

        // Find the selections
        let selections: [(range: XCSourceTextRange, originalIndex: Int)] = buffer.selections.enumerated().compactMap({ item -> (range: XCSourceTextRange, originalIndex: Int)? in
            let originalIndex: Int = item.offset
            guard let selectedRange: XCSourceTextRange = item.element as? XCSourceTextRange else { return nil }

            if selectedRange.isInsertionPoint, selectedRange.start.line < buffer.lines.count {
                // Insertion point implies "this entire line"
                return (range: XCSourceTextRange(
                    start: XCSourceTextPosition(line: selectedRange.start.line, column: 0),
                    end: XCSourceTextPosition(line: selectedRange.start.line + 1, column: 0)
                ), originalIndex: originalIndex)
            } else {
                return (range: selectedRange.copy() as! XCSourceTextRange, originalIndex: originalIndex)
            }
        })

        var selectionsTopDown = selections.sorted(by: { $0.range < $1.range })

        // Since each line modification might be inserting additional lines, we'll need to keep track of the changed line count before each insertion.
        // let beginningLineCount: Int = buffer.lines.count

        (0..<selectionsTopDown.count).forEach { selectionsTopDownIndex in
            let selectionRange: XCSourceTextRange = selectionsTopDown[selectionsTopDownIndex].range
            // let originalStartPosition = selectionRange.start

            // Since we're performing these selections from the top down, we can assume any additional lines are above the current selection.
            // let lineOffset = (buffer.lines.count - beginningLineCount)
            // let lineToModify = originalStartPosition.line + lineOffset

            // let startPosition = XCSourceTextPosition(line: lineToModify, column: originalStartPosition.column)

            // let range = XCSourceTextRange(start: startPosition, end: XCSourceTextPosition(line: originalRange.end.line + lineOffset, column: originalRange.end.column))
            let range = selectionRange
            let startPosition = selectionRange.start
            let lineToModify = startPosition.line

            let duplicatingContent = buffer.string(in: range)

            let additionalLineCount = duplicatingContent.reduce(into: 0) { result, character in
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
            if additionalLineCount > 0 {
                let newIndexes = IndexSet((0..<additionalLineCount).map({ $0 + lineToModify }))
                buffer.lines.insert((0..<additionalLineCount).map({ _ in "" }), at: newIndexes)
            }

            // Modify the buffer content to include the duplication
            buffer.lines[lineToModify] = lineContent

            let columnOffset = duplicatingContent.count
            // Modify the selection so it remains on the text that was duplicated.
            // And modify all of the subsequent selections by the same distance so when we perform those duplications, it's done on the new location of each selection.
            // Note that the buffer selection range and the one we are working with in each of these items is subtly different due to the first pass. So we'll move them individually.
            (selectionsTopDownIndex..<selectionsTopDown.count).forEach { modifyingIndex in
                let item = selectionsTopDown[modifyingIndex]
                if additionalLineCount > 0 {
                    // If we didn't do this, the selection would have expanded to include both the original and duplicate lines.
                    buffer.selections[item.originalIndex] = (buffer.selections[item.originalIndex] as! XCSourceTextRange).movedBy(lines: additionalLineCount)
                    selectionsTopDown[modifyingIndex].range = selectionsTopDown[modifyingIndex].range.movedBy(lines: additionalLineCount)
                } else if item.range.start.line == lineToModify {
                    // If the selection is on the line we just modified, it got moved over too.
                    buffer.selections[item.originalIndex] = item.range.movedBy(columns: columnOffset)
                    selectionsTopDown[modifyingIndex].range = selectionsTopDown[modifyingIndex].range.movedBy(columns: columnOffset)
                }
            }
        }

        completionHandler(nil)
    }
}
