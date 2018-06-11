//
//  AppDelegate.swift
//  DynamicLauncher
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let id = "io.github.apollozhu.Dynamic"
        defer { NSApp.terminate(nil) }
        let apps = NSRunningApplication
            .runningApplications(withBundleIdentifier: id)
            .filter { $0.isActive }
        if apps.count == 0 {
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: id,
                options: .default,
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
        }
    }
}
