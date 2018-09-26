//
//  Welcome.swift
//  Dynamic
//
//  Created by Apollo Zhu on 9/26/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class Welcome: NSWindowController {
    private static var welcome: Welcome? = nil
    static func show() {
        if welcome == nil {
            welcome = NSStoryboard.main
                .instantiateController(withIdentifier: "setup")
                as? Welcome
        }
        welcome?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        welcome?.window?.makeKeyAndOrderFront(nil)
    }
    static func close() {
        welcome?.close()
        welcome = nil
    }
}
