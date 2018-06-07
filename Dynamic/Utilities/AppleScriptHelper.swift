//
//  AppleScriptHelper.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/7/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa

extension NSAppleScript {
    @discardableResult
    static func run(_ source: String) -> Bool {
        guard let appleScript = NSAppleScript(source: source) else { return false }
        var errorInfo: NSDictionary? = nil
        appleScript.executeAndReturnError(&errorInfo)
        guard let error = errorInfo as? [AnyHashable: Any] else { return true }
        // Handle Error
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Failed to toggle dark mode", comment: "Alert title")
        alert.informativeText = error.reduce("") { "\($0) \($1.key): \($1.value)" }
        alert.alertStyle = .critical
        alert.runModal()
        return false
    }
}
