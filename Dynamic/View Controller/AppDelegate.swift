//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa
import LetsMove

let darkModeKey = "AppleInterfaceStyle"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Setup
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
        
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.target = NSAppearance.self
        statusBarItem.button?.action = #selector(NSAppearance.toggle)
        
        // Listen to Appearance Changes
        UserDefaults.standard.addObserver(self, forKeyPath: darkModeKey,
                                          options: .new, context: nil)
        
        // Listen to Brightness Changes
        ScreenBrightnessObserver.shared.observe(using: update(forBrightness:))
        update(forBrightness: NSScreen.brightness)
    }
    
    private func update(forBrightness brightness: Float) {
        if brightness > 0.5 {
            NSAppearance(named: .aqua)?.enable()
        } else {
            NSAppearance(named: .darkAqua)?.enable()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        let preferred = UserDefaults.standard.string(forKey: darkModeKey)
        let styleName: NSAppearance.Name = preferred == nil ? .aqua : .darkAqua
        // Update only if needed
        let newAppearance = NSAppearance(named: styleName)
        if newAppearance?.isDarkSystemAppearance != NSAppearance.isDarkModeOn {
            NSAppearance.current = newAppearance
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.removeObserver(self, forKeyPath: darkModeKey)
    }
}
