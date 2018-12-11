//
//  ScreenBrightnessObserver.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import AppKit

extension Notification.Name {
    static let brightnessDidChange = Notification.Name(
        "com.apple.AmbientLightSensorHID.PreferencesChanged"
    )
}

final class ScreenBrightnessObserver: NSObject {
    static let shared = ScreenBrightnessObserver()

    public func start(withInitialUpdate: Bool = true) {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(updateForBrightnessChange),
            name: .brightnessDidChange,
            object: nil
        )
        guard withInitialUpdate else { return }
        updateForBrightnessChange()
    }

    public var mode: AppleInterfaceStyle? {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        switch brightness {
        case 0..<threshold:
            return .darkAqua
        case threshold...1:
            return .aqua
        default:
            // The NoSense here is from the "AppleNoSenseDisplay" in IOKit
            log(.fault, "Dynamic Dark Mode - No Sense Brightness Fetched")
            return nil
        }
    }
    
    @objc private func updateForBrightnessChange() {
        guard let mode = self.mode else { return }
        AppleScript.checkPermission(onSuccess: mode.enable)
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
        guard #available(OSX 10.14, *) else { return }
        let isDarkModeOn = AppleInterfaceStyle.isDark
        let styleName: NSAppearance.Name = isDarkModeOn ? .aqua : .darkAqua
        NSAppearance.current = NSAppearance(named: styleName)
    }
}
