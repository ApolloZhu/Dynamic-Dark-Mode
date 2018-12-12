//
//  AppearanceSwitcher.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
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
    @available(OSX 10.14, *)
    var isDark: Bool! {
        switch name {
        case .aqua, .accessibilityHighContrastAqua:
            return false
        case .darkAqua, .accessibilityHighContrastDarkAqua:
            return true
        default:
            log(.error, "Dynamic - Checking Non-System Appearance")
            return false
        }
    }
}

extension AppleInterfaceStyle {
    static var current: AppleInterfaceStyle {
        get {
            return UserDefaults.standard.string(forKey: darkModeUserDefaultsKey)
                == nil ? .aqua : .darkAqua
        }
        set {
            UserDefaults.standard.set(
                newValue == .aqua ? nil : "Dark",
                forKey: darkModeUserDefaultsKey
            )
        }
    }
    
    static var isDark: Bool {
        if #available(OSX 10.14, *), NSAppearance.current.isDark == true {
            return true
        }
        return AppleInterfaceStyle.current == .darkAqua
    }
    
    // MARK: - Toggle Dark Mode

    static func toggle() {
        AppleScript.toggleDarkMode.execute()
    }
    
    func enable() {
        if self == .darkAqua {
            AppleScript.enableDarkMode.execute()
        } else {
            AppleScript.disableDarkMode.execute()
        }
    }
}
