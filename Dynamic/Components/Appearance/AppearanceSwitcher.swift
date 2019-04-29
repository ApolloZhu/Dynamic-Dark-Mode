//
//  AppearanceSwitcher.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Foundation
import Cocoa

// MARK: - Detect Dark Mode

let darkModeUserDefaultsKey = "AppleInterfaceStyle"

public enum AppleInterfaceStyle: String {
    case aqua
    case darkAqua
}

extension NSAppearance {
    var isDark: Bool {
        switch name {
        case .aqua, .accessibilityHighContrastAqua,
             .vibrantLight, .accessibilityHighContrastVibrantLight:
            return false
        case .darkAqua, .accessibilityHighContrastDarkAqua,
             .vibrantDark, .accessibilityHighContrastVibrantDark:
            return true
        default:
            #if DEBUG
            fatalError(name.rawValue)
            #else
            debugPrint("Dynamic Dark Mode - Unrecognized appearance: \(name.rawValue)")
            return false
            #endif
        }
    }
}

extension AppleInterfaceStyle {
    static var current: AppleInterfaceStyle {
        return isDark ? .darkAqua : .aqua
    }

    static var isDark: Bool {
        return NSAppearance.current.isDark
    }
    
    // MARK: - Toggle Dark Mode

    static func toggle() {
        AppleScript.toggleDarkMode.execute()
    }
    
    func enable() {
        switch self {
        case .aqua:
            AppleScript.disableDarkMode.execute()
        case .darkAqua:
            AppleScript.enableDarkMode.execute()
        }
    }
}
