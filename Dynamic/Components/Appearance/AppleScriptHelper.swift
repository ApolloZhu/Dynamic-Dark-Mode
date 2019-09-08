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
    /// Switches dark mode and [returns focus back to the original app](
    ///   https://discussions.apple.com/thread/6820749?answerId=27630325022#27630325022
    /// )
    ///
    /// - Note: It doesn't work if an [LSUIElement is focused](
    ///   http://hints.macworld.com/article.php?story=20060110152311698
    /// )
    private var source: String {
        return """
        tell application "System Events"
            tell appearance preferences to set dark mode to \(rawValue)
        end tell
        """
    }
}

// MARK: - Execution

extension AppleScript {
    public func execute() {
        let frontmostApplication = NSWorkspace.shared.frontmostApplication
        AppleScript.checkPermission {
            var errorInfo: NSDictionary? = nil
            NSAppleScript(source: self.source)!
                .executeAndReturnError(&errorInfo)
            frontmostApplication?.activate(options: [.activateIgnoringOtherApps])
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
