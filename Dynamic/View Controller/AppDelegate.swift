//
//  AppDelegate.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import AppKit
import UserNotifications
#if canImport(LetsMove)
import LetsMove
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif
        
        UNUserNotificationCenter.current().delegate = self
        TouchBar.setup()
        Shortcut.startObserving()
        if #available(macOS 10.15, *), preferences.AppleInterfaceStyleSwitchesAutomatically {
            Shortcut.stopObserving()
            preferences.scheduleZenithType = .system
        }
        if preferences.hasLaunchedBefore {
            Preferences.setupDefaultsForNewFeatures()
            Preferences.startObserving()
            AppleInterfaceStyle.Coordinator.setup()
        } else {
            Welcome.show()
        }
    }
    
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        reopen()
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Welcome.close()
        TouchBar.tearDown()
        Preferences.stopObserving()
        AppleInterfaceStyle.Coordinator.tearDown()
    }
}

func reopen() {
    if preferences.hasLaunchedBefore {
        SettingsViewController.show()
    } else {
        Welcome.show()
    }
}
