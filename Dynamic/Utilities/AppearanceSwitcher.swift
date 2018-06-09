//
//  AppearanceSwitcher.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Foundation
import os.log
import AppKit

// MARK: - Toggle Dark Mode

extension NSAppearance {
    @discardableResult @objc
    static func toggle() -> Bool {
        return NSAppleScript.run("""
            tell application "System Events"
                tell appearance preferences to set dark mode to not dark mode
            end tell
            """)
    }
}

// MARK: Detect Dark Mode

extension NSAppearance {
    static var isDarkModeOn: Bool {
        return current.isDarkSystemAppearance == true
    }
    
    var isDarkSystemAppearance: Bool? {
        switch self.name {
        case .aqua, .accessibilityHighContrastAqua:
            return false
        case .darkAqua, .accessibilityHighContrastDarkAqua:
            return true
        default:
            os_log("Not system appearance", log: .default, type: .error)
            return nil
        }
    }
}

// MARK: Enable Apperance

extension NSAppearance {
    @discardableResult
    func enable() -> Bool {
        guard self != NSAppearance.current else { return true }
        guard let isDarkMode = isDarkSystemAppearance else { return false }
        return NSAppleScript.run("""
            tell application "System Events"
            tell appearance preferences to set dark mode to \(isDarkMode)
            end tell
            """)
    }
}
