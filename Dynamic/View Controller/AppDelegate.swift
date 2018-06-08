//
//  AppDelegate.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa

let darkModeKey = "AppleInterfaceStyle"
let kDisplayServicesBrightness = "DisplayServicesBrightness"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Setup
    private lazy var statusBarItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.squareLength)
 
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem.button?.target = NSAppearance.self
        statusBarItem.button?.action = #selector(NSAppearance.toggle)
        
        // Listen to Appearance Changes
        UserDefaults.standard.addObserver(self, forKeyPath: darkModeKey,
                                          options: .new, context: nil)
        
        // Listen to Brightness Changes
        loadPrivateFramework(named: "CoreDuelContext")
        loadPrivateFramework(named: "CoreBrightness")
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
