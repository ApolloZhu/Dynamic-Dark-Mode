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
    /// Turns dark mode on/off/to the opposite.
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
        AppleScript.requestPermission { authorized in
            guard authorized else {
                return AppleScript.showErrorThenRedirect(orRetry: self.execute)
            }
            // Do the job
            var errorInfo: NSDictionary? = nil
            NSAppleScript(source: self.source)!
                .executeAndReturnError(&errorInfo)
            frontmostApplication?.activate(options: [.activateIgnoringOtherApps])
            // Handle errors
            guard let error = errorInfo else { return }
            remindReportingBug(info: error, title: NSLocalizedString(
                "AppleScript.execute.error",
                value: "Failed to Toggle Dark Mode",
                comment: "Something went wrong. But it's okay"
            ))
            AppleScript.ignorePermissionChecking = false
        }
    }
}

// MARK: - Permission

extension AppleScript {
    public static func showErrorThenRedirect(orRetry retry: @escaping () -> Void) {
        showAlert(withConfiguration: { alert in
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
            alert.addButton(withTitle: NSLocalizedString(
                "AppleScript.authorization.goToSystemPreferences",
                value: "OK",
                comment: "Go to System Preferences"
            ))
            alert.addButton(withTitle: NSLocalizedString(
                "AppleScript.authorization.nope",
                value: "Not true",
                comment: "User thinks they have given us permission to control System Events"
            ))
        }, then: { response in
            switch response {
            case .alertFirstButtonReturn:
                redirectToSystemPreferences()
            case .alertSecondButtonReturn:
                ignorePermissionChecking = true
                retry()
            default:
                fatalError("Unhandled AppleScript permission check response")
            }
        })
    }
    
    public static func redirectToSystemPreferences() {
        openURL("x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")
    }
    
    private static var ignorePermissionChecking: Bool = false
    
    public static func requestPermission(
        retryOnInternalError: Bool = true,
        then process: @escaping Handler<Bool>
    ) {
        if ignorePermissionChecking { return process(true) }
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
