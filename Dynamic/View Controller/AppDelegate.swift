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
        
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.action = #selector(handleEvent)
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // MARK: Control Strip Setup
        #warning("Consider to add an optiion in settings to let the user choose whether or not to display the item in Control Strip?")
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        let identifier = NSTouchBarItem.Identifier(rawValue: "io.github.apollozhu.Dynamic.switch")
        let item = NSCustomTouchBarItem(identifier: identifier)
        #warning("TODO: Change the button image when toggled")
        let button = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(controlStripItemTapped(_:)))
        item.view = button
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(identifier, true)

        // MARK: Other Setup
        
        AppleScript.setupIfNeeded()
        if !Preferences.hasLaunchedBefore {
            Preferences.setup()
            SettingsViewController.show()
        }
        _ = ScreenBrightnessObserver.shared
        Preferences.reload()
    }

    @objc private func controlStripItemTapped(_ sender: NSButton) {
        AppleInterfaceStyle.toggle()
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
