//
//  AppDelegate.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import AppKit
import UserNotifications
import MASShortcut
#if canImport(LetsMove)
import LetsMove
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if canImport(LetsMove) && !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif

        StatusBarItem.only.startObserving()

        UNUserNotificationCenter.current().delegate = Scheduler.shared

        // Command-Shift-T
        MASShortcutBinder.shared()?.bindShortcut(
            withDefaultsKey: preferences.toggleShortcutKey,
            toAction: toggleInterfaceStyle
        )

        DispatchQueue.global(qos: .userInteractive).async(execute: setup)
        DispatchQueue.global(qos: .userInitiated).async(execute: setupTouchBar)
    }
    
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsViewController.show()
        return false
    }

    // MARK: - Control Strip Setup

    private func setupTouchBar() {
        #if Masless
        #warning("TODO: Add option to disable displaying toggle button in Control Strip")
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        let identifier = NSTouchBarItem.Identifier(rawValue: "io.github.apollozhu.Dynamic.switch")
        let item = NSCustomTouchBarItem(identifier: identifier)
        #warning("TODO: Redesign icon for toggle button")
        let button = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(toggleInterfaceStyle))
        item.view = button
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(identifier, true)
        #endif
    }

    @objc private func toggleInterfaceStyle() {
        AppleInterfaceStyle.toggle()
    }

    // MARK: - Other Setup

    private func setup() {
        if preferences.hasLaunchedBefore {
            startUpdating()
        } else {
            DispatchQueue.main.async(execute: Welcome.show)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        releasePresentors()
        StatusBarItem.only.stopObserving()
        Preferences.removeObservers()
        Scheduler.shared.cancel()
        ScreenBrightnessObserver.shared.stop()
    }
}

func startUpdating(then onComplete: (() -> Void)? = nil) {
    setDefaultToggleShortcut()
    func enableStyleWithPermission(style: AppleInterfaceStyle) {
        AppleScript.requestPermission {
            defer { onComplete?() }
            guard $0 else { return }
            style.enable()
        }
    }
    DispatchQueue.main.async {
        Preferences.setupObservers()
        let basedOnBrightness = preferences.adjustForBrightness
            ? ScreenBrightnessObserver.shared.mode
            : nil
        guard preferences.scheduled else {
            guard let style = basedOnBrightness else { onComplete?();return }
            return enableStyleWithPermission(style: style)
        }
        Scheduler.shared.getCurrentMode {
            if let style = $0?.style ?? basedOnBrightness {
                enableStyleWithPermission(style: style)
            } else {
                alertLocationNotAvailable(dueTo: $1!)
                onComplete?()
            }
        }
    }
}

private func setDefaultToggleShortcut() {
    guard preferences.value(forKey: preferences.toggleShortcutKey) == nil else { return }
    let event = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [.command, .shift], timestamp: 0, windowNumber: 0, context: nil, characters: "T", charactersIgnoringModifiers: "t", isARepeat: false, keyCode: UInt16(kVK_ANSI_T))
    let shortcut = MASShortcut(event: event)!
    let shortcuts = [preferences.toggleShortcutKey: shortcut]
    MASShortcutBinder.shared()?.registerDefaultShortcuts(shortcuts)
    let data = try! NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: true)
    preferences.setPreferred(to: data, forKey: preferences.toggleShortcutKey)
}
