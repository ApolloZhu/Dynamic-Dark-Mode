//
//  AppDelegate.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import AppKit
import UserNotifications
#if canImport(LetsMove)
import LetsMove
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if canImport(LetsMove) && !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif
        
        UNUserNotificationCenter.current().delegate = self
        TouchBar.setup()
        Shortcut.startObserving()
        Preferences.startObserving()
        
        if preferences.hasLaunchedBefore {
            AppleInterfaceStyle.coordinator.setup()
        } else {
            Welcome.show()
        }
    }
    
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsViewController.show()
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Welcome.close()
        Preferences.stopObserving()
        AppleInterfaceStyle.coordinator.tearDown()
    }
}
