//
//  ScreenBrightnessObserver.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import Schedule

final class ScreenBrightnessObserver: NSObject {

    private var notificationPort: IONotificationPortRef?
    private let queue = DispatchQueue(label: "ddm.queue.brightness")
    private lazy var lastBrightness = NSScreen.brightness
    private var callback: IOServiceInterestCallback = { (ctx, service, messageType, messageArgument) in
        guard let ctx = ctx else { return }
        let observer = Unmanaged<ScreenBrightnessObserver>.fromOpaque(ctx).takeUnretainedValue()
        let newBrightness = NSScreen.brightness
        guard observer.lastBrightness != newBrightness else { return }
        observer.lastBrightness = newBrightness
        observer.setNeedsUpdate()
    }

    static let shared = ScreenBrightnessObserver()
    private override init() { super.init() }
    deinit { stopObserving() }

    public func startObserving(withInitialUpdate: Bool = true) {
        stopObserving()
        defer { if withInitialUpdate { setNeedsUpdate() } }
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleBacklightDisplay"))
        guard service != IO_OBJECT_NULL else {
            #if DEBUG
            fatalError("AppleBacklightDisplay is IO_OBJECT_NULL")
            #else
            return remindReportingBug(NSLocalizedString(
                "ScreenBrightnessObserver.startObserving.failed",
                value: "Cannot observe screen brightness change.",
                comment: "Notification text for bug report"
            ))
            #endif
        }
        defer { IOObjectRelease(service) }
        notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
        IONotificationPortSetDispatchQueue(notificationPort, queue)
        var n = io_object_t()
        let ctx = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        IOServiceAddInterestNotification(notificationPort, service, kIOGeneralInterest, callback, ctx, &n)
        lastBrightness = NSScreen.brightness
    }

    public var suggestedMode: AppleInterfaceStyle {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        return brightness < threshold ? .darkAqua : .aqua
    }
    
    private var task: Task?
    private func setNeedsUpdate() {
        task = Plan.after(0.5.seconds).do(queue: .main, action: _updateForBrightnessChange)
    }
    
    private func _updateForBrightnessChange() {
        let newValue = suggestedMode
        guard AppleInterfaceStyle.current != newValue else { return }
        newValue.enable()
    }

    public func stopObserving() {
        guard notificationPort != nil else { return }
        IONotificationPortDestroy(notificationPort)
        notificationPort = nil
    }
}
