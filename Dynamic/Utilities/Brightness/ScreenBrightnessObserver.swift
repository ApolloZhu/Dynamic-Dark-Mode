//
//  ScreenBrightnessObserver.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import AppKit
import os.log

extension Notification.Name {
    static let brightnessDidChange = Notification.Name(
        "com.apple.AmbientLightSensorHID.PreferencesChanged"
    )
}

final class ScreenBrightnessObserver: NSObject {
    static let shared = ScreenBrightnessObserver()
    
    public func start() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(updateForBrightnessChange),
            name: .brightnessDidChange,
            object: nil
        )
        updateForBrightnessChange()
    }
    
    @objc private func updateForBrightnessChange() {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        switch brightness {
        case 0..<threshold:
            AppleInterfaceStyle.darkAqua.enable()
        case threshold...1:
            AppleInterfaceStyle.aqua.enable()
        default:
            // The NoSense here is from the "AppleNoSenseDisplay" in IOKit
            log(.fault, "Dynamic - No Sense Brightness Fetched")
        }
    }
    
    public func stop() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    deinit {
        stop()
        // MARK: - Update Anyways
        UserDefaults.standard.removeObserver(
            self, forKeyPath: darkModeUserDefaultsKey
        )
    }

    
    private override init() {
        super.init()
        // Listen to Appearance Changes
        UserDefaults.standard.addObserver(
            self, forKeyPath: darkModeUserDefaultsKey,
            options: .new, context: nil
        )
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        let isDarkModeOn = AppleInterfaceStyle.isDark
        guard #available(OSX 10.14, *) else { return }
        let styleName: NSAppearance.Name = isDarkModeOn ? .aqua : .darkAqua
        NSAppearance.current = NSAppearance(named: styleName)
    }
}
