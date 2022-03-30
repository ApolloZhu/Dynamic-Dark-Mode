//
//  AppleInterfaceStyle.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import Foundation

public enum AppleInterfaceStyle: String {
    case aqua
    case darkAqua
}

// MARK: - Toggle Dark Mode

extension AppleInterfaceStyle {
    
    static func toggle() {
        AppleScript.toggleDarkMode.execute()
    }
    
    func enable() {
        guard AppleInterfaceStyle.current != self else { return }
        switch self {
        case .aqua:
            AppleScript.disableDarkMode.execute()
        case .darkAqua:
            AppleScript.enableDarkMode.execute()
        }
    }
    
    static func updateWallpaper() {
        guard let url = isDark
            ? preferences.darkDesktopURL
            : preferences.lightDesktopURL
            else { return }
        let workspace = NSWorkspace.shared
        for screen in NSScreen.screens {
            try? workspace.setDesktopImageURL(url, for: screen)
        }
    }
    
}
