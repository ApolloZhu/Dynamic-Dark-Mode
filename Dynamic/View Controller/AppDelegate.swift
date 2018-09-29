//
//  AppDelegate.swift
//  Dynamic
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
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
    private var settingsStyleObservation: NSKeyValueObservation?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if canImport(LetsMove) && !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif

        UNUserNotificationCenter.current().delegate = Scheduler.shared

        // Command-Shift-T
        MASShortcutBinder.shared()?.bindShortcut(
            withDefaultsKey: preferences.toggleShortcutKey,
            toAction: toggleInterfaceStyle
        )

        // MARK: - Menu Bar Item Setup
        
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusBarItem.button?.action = #selector(handleEvent)
        settingsStyleObservation = preferences.observe(\.rawSettingsStyle, options: [.initial, .new])
        { [weak self] _, change in
            guard let self = self else { return }
            if change.newValue == 1 {
                self.statusBarItem.menu = self.buildMenu()
            } else {
                self.statusBarItem.menu = nil
            }
        }

        DispatchQueue.global(qos: .userInteractive).async(execute: setup)
        DispatchQueue.global(qos: .userInitiated).async(execute: setupTouchBar)
    }

    @objc private func handleEvent() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            SettingsViewController.show()
        } else {
            AppleInterfaceStyle.toggle()
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let toggleItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.toggle",
                value: "Toggle Dark Mode",
                comment: "Action item to toggle in from menu bar"),
            action: #selector(toggleInterfaceStyle),
            keyEquivalent: ""
        )
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        let preferencesItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.preferences",
                value: "Preferences…",
                comment: "Settings"),
            action: #selector(SettingsViewController.show),
            keyEquivalent: ","
        )
        preferencesItem.keyEquivalentModifierMask = .command
        preferencesItem.target = SettingsViewController.self
        menu.addItem(preferencesItem)
        let quitItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.quit",
                value: "Quit",
                comment: "Use system translation for quit"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "Q"
        )
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        return menu
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
            start()
        } else {
            Preferences.setup()
            DispatchQueue.main.async(execute: Welcome.show)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        settingsStyleObservation?.invalidate()
        Preferences.removeObservers()
        Scheduler.shared.cancel()
    }
}

private var started = false
func start() {
    setDefaultToggleShortcut()
    if started { return }
    started = true
    DispatchQueue.main.async {
        Preferences.setupObservers()
        AppleScript.checkPermission()
        _ = ScreenBrightnessObserver.shared
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
