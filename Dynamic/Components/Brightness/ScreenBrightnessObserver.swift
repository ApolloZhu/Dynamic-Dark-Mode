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
    var callback: IOServiceInterestCallback = { (ctx, service, messageType, messageArgument) in
        guard let ctx = ctx else { return }
        let observer = Unmanaged<ScreenBrightnessObserver>.fromOpaque(ctx).takeUnretainedValue()
        observer.setNeedsUpdate()
    }

    static let shared = ScreenBrightnessObserver()
    private override init() { super.init() }
    deinit { stopObserving() }

    public func startObserving(withInitialUpdate: Bool = true) {
        print(#function)
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
    }

    public var suggestedMode: AppleInterfaceStyle {
        let brightness = NSScreen.brightness
        let threshold = preferences.brightnessThreshold
        return brightness < threshold ? .darkAqua : .aqua
    }
    
    private var taskCount: UInt64 = 0
    private func setNeedsUpdate() {
        taskCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            defer {
                if self.taskCount > 0 {
                    self.taskCount -= 1
                }
            }
            guard self.taskCount <= 1 else { return }
            self._updateForBrightnessChange()
        }
    }
    
    private func _updateForBrightnessChange() {
        let newValue = suggestedMode
        print(newValue)
        guard AppleInterfaceStyle.current != newValue else { return }
        newValue.enable()
    }

    public func stopObserving() {
        guard notificationPort != nil else { return }
        IONotificationPortDestroy(notificationPort)
        notificationPort = nil
    }
}
