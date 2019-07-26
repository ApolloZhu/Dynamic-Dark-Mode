//
//  ScreenBrightnessObserver.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

final class ScreenBrightnessObserver: NSObject {

    var notificationPort: IONotificationPortRef?
    let queue = DispatchQueue(label: "ddm.queue")
    lazy var currentMode: AppleInterfaceStyle = suggestedMode
    var callback: IOServiceInterestCallback = { (ctx, service, messageType, messageArgument) -> Void in
        if let ctx = ctx {
            let observer = Unmanaged<ScreenBrightnessObserver>.fromOpaque(ctx).takeUnretainedValue()
            observer.updateForBrightnessChange()
        }
    }

    static let shared = ScreenBrightnessObserver()
    private override init() { super.init() }
    deinit { stopObserving() }

    public func startObserving(withInitialUpdate: Bool = true) {
        stopObserving()
        currentMode = suggestedMode
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleBacklightDisplay"))
        if service == IO_OBJECT_NULL {
            return
        }

        notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
        IONotificationPortSetDispatchQueue(notificationPort, queue)
        var n = io_object_t()
        let ctx = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        IOServiceAddInterestNotification(notificationPort, service, kIOGeneralInterest, callback, ctx, &n)
        IOObjectRelease(service)

        guard withInitialUpdate else { return }
        updateForBrightnessChange()
    }

    public var suggestedMode: AppleInterfaceStyle {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        return brightness < threshold ? .darkAqua : .aqua
    }

    @objc private func updateForBrightnessChange() {
        let value = suggestedMode
        if currentMode != value {
            currentMode = value
            currentMode.enable()
        }
    }

    public func stopObserving() {
        if nil != notificationPort {
            IONotificationPortDestroy(notificationPort)
            notificationPort = nil
        }
    }
}
