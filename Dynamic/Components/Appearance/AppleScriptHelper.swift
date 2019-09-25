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

// MARK: - Execution

extension AppleScript {
    public func execute() {
        let frontmostApplication = NSWorkspace.shared.frontmostApplication
        AppleScript.requestPermission { authorized in
            defer { frontmostApplication?.activate(options: [.activateIgnoringOtherApps]) }
            
            if authorized {
                self.useAppleScriptImplementation()
            } else {
                self.useNonAppStoreCompliantImplementation()
            }
        }
    }
    
    // MARK: Deprecated API
    
    /// Turns dark mode on/off/to the opposite.
    private var source: String {
        return """
        tell application "System Events"
            tell appearance preferences to set dark mode to \(rawValue)
        end tell
        """
    }
    
    private func useAppleScriptImplementation() {
        var errorInfo: NSDictionary? = nil
        NSAppleScript(source: self.source)!
            .executeAndReturnError(&errorInfo)
        // Handle errors
        if errorInfo != nil {
            useNonAppStoreCompliantImplementation()
        }
    }
    
    // MARK: Private API
    
    private func useNonAppStoreCompliantImplementation() {
        switch self {
        case .toggleDarkMode:
            SLSSetAppearanceThemeLegacy(!SLSGetAppearanceThemeLegacy())
        case .enableDarkMode:
            SLSSetAppearanceThemeLegacy(true)
        case .disableDarkMode:
            SLSSetAppearanceThemeLegacy(false)
        }
    }
}

// MARK: - Permission

extension AppleScript {
    public static let notAuthorized = NSLocalizedString(
        "AppleScript.authorization.error",
        value: "You didn't allow Dynamic Dark Mode to manage dark mode",
        comment: ""
    )
    
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
                } // else ignore
            default:
                remindReportingBug("OSStatus \(status)")
            }
            process(false)
        }
    }
}
