//
//  ScriptSetupViewController.swift
//  Dynamic
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class ScriptSetupViewController: NSViewController {
    private var token: NSKeyValueObservation?
    override func viewDidAppear() {
        super.viewDidAppear()
        if preferences.didSetupAppleScript {
            performSegue(withIdentifier: "next", sender: nil)
        }
        token = preferences.observe(\.didSetupAppleScript,
                                    options: [.initial, .new])
        { [weak self] _, change in
            guard change.newValue == true else { return }
            self?.performSegue(withIdentifier: "next", sender: nil)
        }
        AppleScript.setupIfNeeded()
    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        token?.invalidate()
    }
}
