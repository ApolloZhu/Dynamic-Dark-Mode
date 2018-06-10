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
    
    fileprivate static let folder = try! FileManager.default.url(
        for: .applicationScriptsDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    fileprivate var url: URL {
        return AppleScript.folder.appendingPathComponent(name)
    }
}

// MARK: Execution

extension AppleScript {
    public func execute() {
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
    }
}

// MARK: - Dirty Work

extension AppleScript {
    public static func setupOnce() {
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
            return /*to*/ setupOnce() /*again*/
        }
        letsMove()
    }
    
    private static func letsMove() {
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
