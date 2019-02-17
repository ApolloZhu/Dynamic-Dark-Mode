//
//  AllowSystemEventsViewController.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class AllowSystemEventsViewController: NSViewController, SetupStep {
    override func viewDidAppear() {
        super.viewDidAppear()
        AppleScript.requestPermission { authorized in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    self?.showNext()
                } else {
                    self?.showPreferences.isHidden = false
                }
            }
        }
    }
    
    @IBOutlet weak var showPreferences: NSButton!
    @IBAction func openPreferences(_ sender: NSButton) {
        AppleScript.requestPermission { [weak self] authorized in
            if authorized {
                self?.showNext()
            } else {
                AppleScript.redirectToSystemPreferences()
            }
        }
    }
}
