//
//  Welcome.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/26/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class Welcome: NSWindowController {
    private static var welcome: Welcome? = nil
    
    public static func show() {
        if welcome == nil {
            welcome = NSStoryboard.main
                .instantiateController(withIdentifier: "setup")
                as? Welcome
            rewindSetupSteps()
            setupSteps.append(welcome!.contentViewController!)
        }
        welcome?.window?.level = .floating
        welcome?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        welcome?.window?.makeKeyAndOrderFront(nil)
    }
    
    public static func skip() {
        Welcome.close()
        preferences.hasLaunchedBefore = true
        Preferences.setupAsSuggested()
        Preferences.startObserving()
        AppleInterfaceStyle.Coordinator.setup()
        SettingsViewController.show()
    }
    
    public static func close() {
        welcome?.close()
        rewindSetupSteps()
        welcome = nil
    }
}
