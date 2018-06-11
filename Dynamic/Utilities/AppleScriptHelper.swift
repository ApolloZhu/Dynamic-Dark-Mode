//
//  AppleScriptHelper.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/7/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import AppKit

// MARK: - All Apple Scripts

public enum AppleScript: String, CaseIterable {
    case toggleDarkMode = "toggle"
    case enableDarkMode = "on"
    case disableDarkMode = "off"
}

// MARK: - Handy Properties

extension AppleScript {
    fileprivate var name: String {
        return "\(rawValue).scpt"
    }
    
    fileprivate static let folder = Bundle.main.bundleURL
    /*try! FileManager.default.url(
        for: .applicationScriptsDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )*/
    
    fileprivate var url: URL {
        return AppleScript.folder.appendingPathComponent(name)
    }
}

// MARK: Execution

extension AppleScript {
    public static var isExecutable: Bool {
        let env = ProcessInfo.processInfo.environment
        return !env.keys.contains("APP_SANDBOX_CONTAINER_ID")
    }
    
    public func execute() {
        var error: NSDictionary? = nil
        let script = NSAppleScript(contentsOf: url, error: &error)
        script?.executeAndReturnError(&error)
        guard let info = error else { return }
        let alert = NSAlert()
        alert.messageText = ""
        alert.informativeText = info.reduce("") {
            "\($0)\($1.key): \($1.value)\n"
        }
        alert.runModal()
    }
}
