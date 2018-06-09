//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import AppKit
import os.log

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Setup
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.action = #selector(toggleAppearance)
        
        // Listen to Appearance Changes
        UserDefaults.standard.addObserver(
            self, forKeyPath: darkModeUserDefaultsKey,
            options: .new, context: nil
        )
        
        // Listen to Brightness Changes
        ScreenBrightnessObserver.shared.observe(using: update(forBrightness:))
        update(forBrightness: NSScreen.brightness)
    }
    
    private func update(forBrightness brightness: Float) {
        switch brightness {
        case 0..<0.5:
            AppleInterfaceStyle.darkAqua.enable()
        case 0.5...1:
            AppleInterfaceStyle.aqua.enable()
        default:
            #if DEBUG
            // The NoSense here refers to the "AppleNoSenseDisplay" in IOKit
            fatalError("NoSense Brightness")
            #else
            os_log("Dynamic - No Sense Brightness Fetched", type: .error)
            #endif
        }
    }
    
    @objc private func toggleAppearance() {
        AppleInterfaceStyle.toggle()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        let isDarkModeOn = AppleInterfaceStyle.isDark
        #if DEBUG
        print("User Defaults Turned Dark Mode \(isDarkModeOn ? "On" : "Off")")
        #else
        os_log("Dynamic - User Defaults Changed")
        #endif
        guard #available(OSX 10.14, *) else { return }
        let styleName: NSAppearance.Name = isDarkModeOn ? .aqua : .darkAqua
        NSAppearance.current = NSAppearance(named: styleName)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.removeObserver(
            self, forKeyPath: darkModeUserDefaultsKey
        )
    }
}
