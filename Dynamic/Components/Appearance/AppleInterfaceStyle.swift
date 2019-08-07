//
//  AppleInterfaceStyle.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
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
        setDesktop(for: current)
    }
    
    func enable(requestingPermission: Bool = true) {
        if requestingPermission {
            AppleScript.checkPermission {
                self.enable(requestingPermission: false)
            }
        }
        switch self {
        case .aqua:
            AppleScript.disableDarkMode.execute()
        case .darkAqua:
            AppleScript.enableDarkMode.execute()
        }
        AppleInterfaceStyle.setDesktop(for: AppleInterfaceStyle.current)
    }
    
    static func setDesktop(for style: AppleInterfaceStyle) {
        guard let url = style == .aqua ? preferences.lightDesktopURL : preferences.darkDesktopURL else { return }
        let workspace = NSWorkspace.shared
        for screen in NSScreen.screens {
            try? workspace.setDesktopImageURL(url, for: screen, options: [:])
        }
    }

}
