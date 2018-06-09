//
//  ScreenBrightnessObserver.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import AppKit

extension Notification.Name {
    static let brightnessDidChange = Notification.Name(
        "com.apple.AmbientLightSensorHID.PreferencesChanged"
    )
}

final class ScreenBrightnessObserver {
    static let shared = ScreenBrightnessObserver()
    
    typealias ScreenBrightnessChangeHandler = (Float) -> Void
    private var updateHandler: ScreenBrightnessChangeHandler?
    
    public func observe(using block: @escaping ScreenBrightnessChangeHandler) {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(updateForBrightnessChange),
            name: .brightnessDidChange,
            object: nil
        )
        updateHandler = block
    }
    
    @objc private func updateForBrightnessChange() {
        updateHandler?(NSScreen.brightness)
    }
    
    public func stop() {
        updateHandler = nil
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    deinit {
        stop()
    }
}
