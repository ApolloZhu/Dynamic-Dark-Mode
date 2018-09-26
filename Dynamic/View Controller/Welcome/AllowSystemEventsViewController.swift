//
//  AllowSystemEventsViewController.swift
//  Dynamic
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class AllowSystemEventsViewController: NSViewController {
    override func viewDidAppear() {
        super.viewDidAppear()
        let script: AppleScript = AppleInterfaceStyle.isDark
            ? .enableDarkMode : .disableDarkMode
        script.execute { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let error = error else {
                    return self.performSegue(withIdentifier: "next", sender: nil)
                }
                self.presentError(error)
                self.showPreferences.isHidden = false
            }
        }
    }
    @IBOutlet weak var showPreferences: NSButton!
    private var firstClick = true
    @IBAction func openPreferences(_ sender: NSButton) {
        guard firstClick else {
            return performSegue(withIdentifier: "next",
                                sender: nil)
        }
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
        showPreferences.title = NSLocalizedString(
            "Setup.next",
            value: "Next >>",
            comment: "Indicate moving to the next screen"
        )
    }
}
