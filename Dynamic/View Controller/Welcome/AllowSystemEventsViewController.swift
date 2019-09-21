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
    
    @IBAction func skip(_ sender: Any) {
        showNext()
    }
    
    @IBOutlet weak var showPreferences: NSButton!
    @IBAction func openPreferences(_ sender: NSButton) {
        AppleScript.requestPermission { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                self.showNext()
            } else {
                self.needsPermission(AppleScript.notAuthorized,
                                     openPreferences: AppleScript.redirectToSystemPreferences,
                                     skip: self.showNext)
            }
        }
    }
}
