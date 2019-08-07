//
//  DynamicDesktopSettingsViewController.swift
//  Dynamic Dark Mode
//
//  Created by CaptainYukinoshitaHachiman on 8/7/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class DynamicDesktopSettingsViewController: NSViewController {
    
    @IBOutlet weak var lightDesktopButton: NSButton!
    @IBOutlet weak var darkDesktopButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateContents()
    }
    
    private func updateContents() {
        // Since clear will directly dismiss,
        // we only need to handle the cases where there're images set
        if let lightDesktopURL = preferences.lightDesktopURL {
            lightDesktopButton.image = NSImage(byReferencing: lightDesktopURL)
        }
        if let darkDesktopURL = preferences.darkDesktopURL {
            darkDesktopButton.image = NSImage(byReferencing: darkDesktopURL)
        }
    }
    
    @IBAction func clearDesktop(_ sender: Any) {
        preferences.lightDesktopURL = nil
        preferences.darkDesktopURL = nil
        dismiss(nil)
    }
    
    @IBAction func setLightDesktop(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
        openPanel.begin { [unowned self] response in
            if response == .OK {
                preferences.lightDesktopURL = openPanel.url
                self.updateContents()
            }
        }
    }
    
    @IBAction func setDarkDesktop(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
        openPanel.begin { [unowned self] response in
            if response == .OK {
                preferences.darkDesktopURL = openPanel.url
                self.updateContents()
            }
        }
    }
    

    
}
