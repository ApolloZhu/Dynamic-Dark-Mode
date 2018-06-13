//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import AppKit
import os.log
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Setup
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.action = #selector(handleEvent)
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        // MARK: Other Setup
        
        AppleScript.setupIfNeeded()
        if !Preferences.hasLaunchedBefore {
            Preferences.setup()
            SettingsViewController.show()
        }
        _ = ScreenBrightnessObserver.shared
        Preferences.reload()
    }
    
    @objc private func handleEvent() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            SettingsViewController.show()
        } else {
            AppleInterfaceStyle.toggle()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }
}
