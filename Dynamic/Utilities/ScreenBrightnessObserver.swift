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

final class ScreenBrightnessObserver {
    static let shared = ScreenBrightnessObserver()
    private init() { }
    
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
    }
}
