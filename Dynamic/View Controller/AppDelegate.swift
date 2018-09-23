//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import AppKit
import UserNotifications
import os.log
import ServiceManagement
#if canImport(LetsMove)
import LetsMove
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if canImport(LetsMove) && !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif

        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = Scheduler.shared
        } else {
            NSUserNotificationCenter.default.delegate = Scheduler.shared
        }

        // MARK: - Menu Bar Item Setup
        
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusBarItem.button?.action = #selector(handleEvent)

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
        Preferences.setupObservers()
        AppleScript.setupIfNeeded()
        if !preferences.hasLaunchedBefore {
            Preferences.setup()
            DispatchQueue.main.async(execute: SettingsViewController.show)
        }
        _ = ScreenBrightnessObserver.shared
    }

    func applicationWillTerminate(_ notification: Notification) {
        Preferences.removeObservers()
        Scheduler.shared.cancel()
    }
}
