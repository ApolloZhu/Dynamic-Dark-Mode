//
//  OpenSettingsViewController.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class OpenSettingsViewController: NSViewController {
    @IBAction func configureStyle(_ sender: NSButton) {
        preferences.rawSettingsStyle = sender.tag
    }

    @IBAction func start(_ sender: Any) {
        preferences.hasLaunchedBefore = true
        Welcome.close()
        startUpdating()
        SettingsViewController.show()
    }
}
