//
//  Shortcut.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import MASShortcut

enum Shortcut {
    public static func startObserving() {
        setDefaultToggleShortcut()
        MASShortcutBinder.shared()?.bindShortcut(
            withDefaultsKey: Preferences.toggleShortcutKey,
            toAction: AppleInterfaceStyle.Coordinator.toggleOrShowInterface
        ) // will, it will never show interface since it's disabled for that
    }
    
    public static func stopObserving() {
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: Preferences.toggleShortcutKey)
    }
    
    /// Command-Shift-T
    private static func setDefaultToggleShortcut() {
        guard !preferences.exists(Preferences.toggleShortcutKey) else { return }
        let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [.command, .shift],
                                     timestamp: 0, windowNumber: 0, context: nil,
                                     characters: "T", charactersIgnoringModifiers: "t",
                                     isARepeat: false, keyCode: UInt16(kVK_ANSI_T))
        let shortcut = MASShortcut(event: event)!
        let shortcuts = [Preferences.toggleShortcutKey: shortcut]
        MASShortcutBinder.shared()?.registerDefaultShortcuts(shortcuts)
        let data = try! NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: true)
        preferences.setPreferred(to: data, forKey: Preferences.toggleShortcutKey)
    }
}
