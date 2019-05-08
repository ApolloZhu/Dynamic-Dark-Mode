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
    case toggleDarkMode = "toggle"
    case enableDarkMode = "on"
    case disableDarkMode = "off"
}

// MARK: - Handy Properties

extension AppleScript {
    private var name: String {
        return "\(rawValue).scpt"
    }
    
    private static var folder: URL {
        return Bundle.main.resourceURL!
    }
    
    private var url: URL {
        return AppleScript.folder.appendingPathComponent(name)
    }
}

// MARK: - Execution

extension AppleScript {
    public func execute() {
        AppleScript.checkPermission {
            var errorInfo: NSDictionary? = nil
            let script = NSAppleScript(contentsOf: self.url, error: &errorInfo)
            script?.executeAndReturnError(&errorInfo)
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
