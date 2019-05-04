//
//  Shortcut.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import MASShortcut

enum Shortcut {
    public static func startObserving() {
        setDefaultToggleShortcut()
        MASShortcutBinder.shared()?.bindShortcut(
            withDefaultsKey: preferences.toggleShortcutKey,
            toAction: AppleInterfaceStyle.Coordinator.toggleInterfaceStyle
        )
    }
    
    /// Command-Shift-T
    private static func setDefaultToggleShortcut() {
        guard preferences.value(forKey: preferences.toggleShortcutKey) == nil else { return }
        let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [.command, .shift], timestamp: 0, windowNumber: 0, context: nil, characters: "T", charactersIgnoringModifiers: "t", isARepeat: false, keyCode: UInt16(kVK_ANSI_T))
        let shortcut = MASShortcut(event: event)!
        let shortcuts = [preferences.toggleShortcutKey: shortcut]
        MASShortcutBinder.shared()?.registerDefaultShortcuts(shortcuts)
        let data = try! NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: true)
        preferences.setPreferred(to: data, forKey: preferences.toggleShortcutKey)
    }
}
