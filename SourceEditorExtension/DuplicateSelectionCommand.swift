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

        // Find the selections
        let selections: [XCSourceTextRange] = invocation.buffer.selections.compactMap { selectedRange in
            guard let selectedRange = selectedRange as? XCSourceTextRange else { return nil }

            if selectedRange.isInsertionPoint {
                return selectedRange.rangeOfEntireContainingLine
            } else {
                return selectedRange
            }
        }

        // Duplicate the selection(s)
        selections.forEach { range in
            let rangeContent = invocation.buffer.string(in: range)

            guard var modifyingLine = invocation.buffer.lines[range.start.line] as? String else { return }

            let insertionPoint = modifyingLine.index(modifyingLine.startIndex, offsetBy: range.start.column)
            modifyingLine.insert(contentsOf: rangeContent, at: insertionPoint)
        }

        completionHandler(nil)
    }
}
