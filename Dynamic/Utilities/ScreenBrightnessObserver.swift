//
//  ScreenBrightnessObserver.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018 Apollonian. All rights reserved.
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
        #if DEBUG
        print("Brightness Changed to \(brightness)")
        #else
        os_log("Brightness Changed")
        #endif
        let threshold = Preferences.brightnessThreshold
        switch brightness {
        case 0..<threshold:
            AppleInterfaceStyle.darkAqua.enable()
        case threshold...1:
            AppleInterfaceStyle.aqua.enable()
        default:
            #if DEBUG
            // The NoSense here is from the "AppleNoSenseDisplay" in IOKit
            fatalError("NoSense Brightness")
            #else
            os_log("Dynamic - No Sense Brightness Fetched", type: .error)
            #endif
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
        #if DEBUG
        print("User Defaults Turned Dark Mode \(isDarkModeOn ? "On" : "Off")")
        #else
        os_log("Dynamic - User Defaults Changed")
        #endif
        guard #available(OSX 10.14, *) else { return }
        let styleName: NSAppearance.Name = isDarkModeOn ? .aqua : .darkAqua
        NSAppearance.current = NSAppearance(named: styleName)
    }
}
