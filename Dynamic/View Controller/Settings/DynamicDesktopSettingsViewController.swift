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
    @IBOutlet weak var clearButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateContents()
    }
    
    private func updateContents() {
        // Since clear will directly dismiss,
        // we only need to handle the cases where there're images set
        if let lightDesktopURL = preferences.lightDesktopURL {
            lightDesktopButton.image = NSImage(byReferencing: lightDesktopURL)
        } else {
            lightDesktopButton.image = NSImage(named: NSImage.folderName)
        }
        if let darkDesktopURL = preferences.darkDesktopURL {
            darkDesktopButton.image = NSImage(byReferencing: darkDesktopURL)
        } else {
            darkDesktopButton.image = NSImage(named: NSImage.folderName)
        }
        clearButton.isEnabled = preferences.exists(\.lightDesktopURL)
            || preferences.exists(\.darkDesktopURL)
        AppleInterfaceStyle.updateWallpaper()
    }
    
    @IBAction func clearDesktop(_ sender: Any) {
        preferences.lightDesktopURL = nil
        preferences.darkDesktopURL = nil
        updateContents()
    }
    
    @IBAction func setLightDesktop(_ sender: Any) {
        selectImage { [unowned self] url in
            preferences.lightDesktopURL = url
            self.updateContents()
        }
    }
    
    @IBAction func setDarkDesktop(_ sender: Any) {
        selectImage { [unowned self] url in
            preferences.darkDesktopURL = url
            self.updateContents()
        }
    }
    
    private func selectImage(then process: @escaping (URL?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
        openPanel.begin { response in
            guard response == .OK else { return }
            process(openPanel.url)
        }
    }
}
