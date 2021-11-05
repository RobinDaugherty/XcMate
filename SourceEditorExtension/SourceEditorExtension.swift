//
//  SourceEditorExtension.swift
//  SourceEditorExtension
//
//  Created by Robin Daugherty on 2021-11-05.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        debugPrint("SourceEditorExtension extensionDidFinishLaunching")
    }

    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
}
