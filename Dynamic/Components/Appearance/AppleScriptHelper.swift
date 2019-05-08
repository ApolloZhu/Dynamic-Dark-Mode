//
//  AppleScriptHelper.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/7/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

// MARK: - All Apple Scripts

public enum AppleScript: String, CaseIterable {
    case toggleDarkMode = "not dark mode"
    case enableDarkMode = "true"
    case disableDarkMode = "false"
}

// MARK: - Handy Properties

extension AppleScript {
    /// https://discussions.apple.com/thread/6820749?answerId=27630325022#27630325022
    private var source: String {
        #warning("Dynamic Dark Mode itself loses focus")
        return """
        tell application "System Events"
            set frontmostApplicationName to name of 1st process whose frontmost is true
            tell appearance preferences to set dark mode to \(rawValue)
        end tell
        
        tell application frontmostApplicationName
            activate
        end tell
        """
    }
}

// MARK: - Execution

extension AppleScript {
    public func execute() {
        AppleScript.checkPermission {
            var errorInfo: NSDictionary? = nil
            NSAppleScript(source: self.source)!
                .executeAndReturnError(&errorInfo)
            remindReportingBug(info: errorInfo, title: NSLocalizedString(
                "AppleScript.execute.error",
                value: "Failed to Toggle Dark Mode",
                comment: "Something went wrong. But it's okay"
            ))
        }
    }
}

extension AppleScript {
    public static func checkPermission(
        onSuccess: @escaping CompletionHandler = { }
    ) {
        requestPermission { authorized in
            if authorized { return onSuccess() }
            showErrorThenRedirect()
        }
    }
    
    public static func showErrorThenRedirect() {
        runModal(ofNSAlert: { alert in
            alert.alertStyle = .critical
            alert.messageText = NSLocalizedString(
                "AppleScript.authorization.error",
                value: "You didn't allow Dynamic Dark Mode to manage dark mode",
                comment: ""
            )
            alert.informativeText = NSLocalizedString(
                "AppleScript.authorization.instruction",
                value: "We'll take you to System Preferences.",
                comment: ""
            )
        }, then: { _ in
            redirectToSystemPreferences()
        })
    }
    
    public static func redirectToSystemPreferences() {
        openURL("x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")
    }
    
    public static func requestPermission(
        retryOnInternalError: Bool = true,
        then process: @escaping Handler<Bool>
    ) {
        DispatchQueue.global().async {
            let systemEvents = "com.apple.systemevents"
            // We need to get it running to send it messages
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: systemEvents,
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
            let target = NSAppleEventDescriptor(bundleIdentifier: systemEvents)
            let status = AEDeterminePermissionToAutomateTarget(
                target.aeDesc, typeWildCard, typeWildCard, true
            )
            switch Int(status) {
            case Int(noErr):
                return process(true)
            case errAEEventNotPermitted:
                break
            case errOSAInvalidID, -1751,
                 errAEEventWouldRequireUserConsent,
                 procNotFound:
                if retryOnInternalError {
                    requestPermission(retryOnInternalError: false, then: process)
                } else {
                    remindReportingBug(NSLocalizedString(
                        "AppleScript.authorization.failed",
                        value: "Something Went Wrong",
                        comment: "Generic error happened"
                    ), title: "OSStatus \(status)", issueID: 18)
                }
            default:
                remindReportingBug("OSStatus \(status)")
            }
            process(false)
        }
    }
}
