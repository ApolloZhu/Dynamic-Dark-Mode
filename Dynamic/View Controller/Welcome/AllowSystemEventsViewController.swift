//
//  AllowSystemEventsViewController.swift
//  Dynamic
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class AllowSystemEventsViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppleScript.requestPermission() {
            performSegue(withIdentifier: "next", sender: nil)
        } else {
            showPreferences.isHidden = false
        }
    }
    @IBOutlet weak var showPreferences: NSButton!
    @IBAction func openPreferences(_ sender: NSButton) {
        if AppleScript.requestPermission() {
            performSegue(withIdentifier: "next", sender: nil)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
        }
    }
}
