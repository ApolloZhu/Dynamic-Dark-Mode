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
    
    fileprivate static var folder: URL {
        if Sandbox.isOn {
            return try! FileManager.default.url(
                for: .applicationScriptsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
        } else {
            return Bundle.main.resourceURL!
        }
    }
    
    fileprivate var url: URL {
        return AppleScript.folder.appendingPathComponent(name)
    }
}

// MARK: Execution

extension AppleScript {
    public func execute() {
        if Sandbox.isOn {
            do {
                try NSUserAppleScriptTask(url: url).execute { error in
                    guard let error = error else { return }
                    DispatchQueue.main.async {
                        NSAlert(error: error).runModal()
                    }
                }
            } catch {
                NSAlert(error: error).runModal()
            }
        } else {
            var errorInfo: NSDictionary? = nil
            let script = NSAppleScript(contentsOf: url, error: &errorInfo)
            script?.executeAndReturnError(&errorInfo)
            guard let error = errorInfo else { return }
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = NSLocalizedString(
                "appleScriptExecution.error.title",
                value: "Report Critical Bug To Developer",
                comment: "When user sees this, basically this app fails. "
                + "So try to persuade them to report this bug to developer "
                + "so we can fix it earlier."
            )
            alert.informativeText = error.reduce("") {
                "\($0)\($1.key): \($1.value)\n"
            }
            alert.runModal()
        }
    }
}

// MARK: - Dirty Work

extension AppleScript {
    public static func setupIfNeeded() {
        guard Sandbox.isOn else { return }
        let test = folder.appendingPathComponent("test.scpt").path
        if FileManager.default.isWritableFile(atPath: test) { return }
        requestPermission()
    }
    
    private static func requestPermission() {
        let selectPanel = NSOpenPanel()
        selectPanel.directoryURL = folder
        selectPanel.canChooseDirectories = true
        selectPanel.canChooseFiles = false
        selectPanel.prompt = NSLocalizedString(
            "appleScriptFolderSelection.title",
            value: "Select Apple Script Folder",
            comment: ""
        )
        selectPanel.prompt = NSLocalizedString(
            "appleScriptFolderSelection.message",
            value: "Please open this folder so our app can help you manage dark mode",
            comment: "Convince them to open the current folder presented."
        )
        selectPanel.begin { _ in
            handleSelection(selectedURL: selectPanel.url)
        }
    }
    
    private static func handleSelection(selectedURL: URL?) {
        guard selectedURL == folder else {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString(
                "appleScriptFolderSelection.error.title",
                value: "Not Really...",
                comment: "Inform user of their mistake in an interesting way"
            )
            alert.informativeText = NSLocalizedString(
                "appleScriptFolderSelection.error.message",
                value: "You must select the prompted folder for this to work.",
                comment: "Indicate selecting the prompted folder is required"
            )
            alert.runModal()
            return /*to*/ setupIfNeeded() /*again*/
        }
        letsMove()
    }
    
    private static func letsMove() {
        guard Sandbox.isOn else { return }
        for script in allCases {
            let src = Bundle.main.url(forResource: script.name,
                                      withExtension: nil)
            // Just to make sure there is nothing else there
            try? FileManager.default.removeItem(at: script.url)
            // Before we install the scripts
            try! FileManager.default.copyItem(at: src!, to: script.url)
        }
    }
}
