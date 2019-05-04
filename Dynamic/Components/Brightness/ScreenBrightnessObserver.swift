//
//  ScreenBrightnessObserver.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let brightnessDidChange = Notification.Name(
        "com.apple.AmbientLightSensorHID.PreferencesChanged"
    )
}

final class ScreenBrightnessObserver: NSObject {
    static let shared = ScreenBrightnessObserver()
    private override init() { super.init() }
    deinit { stopObserving() }
    
    public func startObserving(withInitialUpdate: Bool = true) {
        stopObserving()
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(updateForBrightnessChange),
            name: .brightnessDidChange,
            object: nil
        )
        guard withInitialUpdate else { return }
        updateForBrightnessChange()
    }
    
    public var mode: AppleInterfaceStyle {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        return brightness < threshold ? .darkAqua : .aqua
    }
    
    @objc private func updateForBrightnessChange() {
        mode.enable()
    }
    
    public func stopObserving() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
}
