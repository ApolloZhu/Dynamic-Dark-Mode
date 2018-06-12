//
//  SettingsViewController.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    public static func show() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let window = storyboard
            .instantiateController(withIdentifier: "window")
            as! NSWindowController
        window.showWindow(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    deinit {
        NSUserDefaultsController.shared.save(nil)
    }
}
