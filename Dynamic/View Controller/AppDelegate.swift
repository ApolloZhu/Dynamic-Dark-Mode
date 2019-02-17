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
        
        let handler = NSGetUncaughtExceptionHandler()

        NSSetUncaughtExceptionHandler { exception in
            runModal(ofNSAlert: { alert in
                alert.alertStyle = .critical
                alert.messageText = NSLocalizedString(
                    "LetsMove",
                    value: "Please move Dynamic Dark Mode to /Applications folder.",
                    comment: "Dynamic Dark Mode must be saved in the system wide Applications folder."
                )
                alert.informativeText = exception.reason ?? ""
                    + "(" + exception.name.rawValue + ")"
            })
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        NSSetUncaughtExceptionHandler(handler)

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
        Preferences.stopObserving()
        Scheduler.shared.cancel()
        ScreenBrightnessObserver.shared.stopObserving()
    }
}

func startUpdating(then onComplete: CompletionHandler? = nil) {
    setDefaultToggleShortcut()
    func enableStyleWithPermission(style: AppleInterfaceStyle) {
        AppleScript.requestPermission {
            defer { onComplete?() }
            guard $0 else { return }
            style.enable()
        }
    }
    DispatchQueue.main.async {
        Preferences.startObserving()
        StatusBarItem.only.startObserving()
        let basedOnBrightness = preferences.adjustForBrightness
            ? ScreenBrightnessObserver.shared.mode
            : nil
        guard preferences.scheduled else {
            guard let style = basedOnBrightness else { onComplete?();return }
            return enableStyleWithPermission(style: style)
        }
        Scheduler.shared.getCurrentMode { result in
            switch result {
            case .success(let mode):
                enableStyleWithPermission(style: mode.style)
            case .failure(let error):
                if let style = basedOnBrightness {
                    enableStyleWithPermission(style: style)
                } else {
                    Location.alertNotAvailable(dueTo: error)
                    onComplete?()
                }
            }
            Scheduler.shared.schedule(enableCurrentStyle: false)
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
