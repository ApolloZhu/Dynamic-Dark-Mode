//
//  Preferences.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import CoreLocation
import ServiceManagement
import MASShortcut

typealias Preferences = UserDefaults
public let preferences = NSUserDefaultsController.shared.defaults

extension Preferences {
    public static func setup() {
        preferences.adjustForBrightness = true
        preferences.brightnessThreshold = 0.5
        // I personally would want this as login item,
        // but that might violate the review guidline.
        #if Masless
        preferences.opensAtLogin = true
        #endif
        preferences.settingsStyle = .menu
        if Location.deniedAccess {
            preferences.scheduleZenithType = .custom
        } else {
            preferences.scheduleZenithType = .official
        }
        preferences.scheduled = true
    }
}

extension Preferences {
    private static var handles: [NSKeyValueObservation] = []

    public static func stopObserving() {
        handles.lazy.forEach { $0.invalidate() }
        handles = []
    }

    public static func startObserving() {
        stopObserving()
        func observe<Value>(
            _ keyPath: KeyPath<UserDefaults, Value>,
            observeInitial: Bool = false,
            changeHandler: @escaping Handler<NSKeyValueObservedChange<Value>>
        ) -> NSKeyValueObservation {
            let options: NSKeyValueObservingOptions =
                observeInitial ? [.initial, .new] : [.new]
            return preferences.observe(keyPath, options: options)
            { _, change in changeHandler(change) }
        }
        if preferences.adjustForBrightness {
            ScreenBrightnessObserver.shared.startObserving(withInitialUpdate: false)
        }
        handles = [
            observe(\.adjustForBrightness) { change in
                ScreenBrightnessObserver.shared.stopObserving()
                if change.newValue == true {
                    ScreenBrightnessObserver.shared.startObserving()
                }
            },
            observe(\.scheduled) { change in
                if change.newValue == true {
                    Scheduler.shared.schedule()
                } else {
                    Scheduler.shared.cancel()
                }
            },
            observe(\.scheduleType) { _ in
                if preferences.scheduled {
                    Scheduler.shared.schedule()
                }
            },
            observe(\.scheduleStart) { _ in
                if preferences.scheduled && preferences.scheduleZenithType == .custom {
                    Scheduler.shared.schedule()
                }
            },
            observe(\.scheduleEnd) { _ in
                if preferences.scheduled && preferences.scheduleZenithType == .custom {
                    Scheduler.shared.schedule()
                }
            },
            observe(\.opensAtLogin, observeInitial: true) { change in
                guard !SMLoginItemSetEnabled(
                    "io.github.apollozhu.Dynamic.Launcher" as CFString,
                    change.newValue ?? true
                ) else { return }
                runModal(ofNSAlert: { alert in
                    alert.messageText = NSLocalizedString(
                        "Preferences.opensAtLogin.failed",
                        value: "Failed to update opens at login settings",
                        comment: """
                        This is used for both enable and disable opens at login.\
                        It indicates the operation to update this settings failed.
                        """
                    )
                })
            }
        ]
    }

    func setPreferred(to value: Any?, forKey key: String = #function) {
        (NSUserDefaultsController.shared.values as AnyObject)
            .setValue(value, forKey: "\(key)")
    }

    @objc dynamic var adjustForBrightness: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    @objc dynamic var brightnessThreshold: Float {
        get {
            if let raw = preferences.value(forKey: #function) as? Double {
                return Float(raw) / 100
            } else {
                setPreferred(to: Double(50))
                return 0.5
            }
        }
        set {
            setPreferred(to: Double(newValue) * 100)
        }
    }
    
    @objc dynamic var scheduled: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }

    @objc dynamic var scheduleType: Int {
        get {
            return preferences.integer(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }

    var scheduleZenithType: Zenith {
        get {
            return Zenith(rawValue: scheduleType) ?? .official
        }
        set {
            scheduleType = newValue.rawValue
        }
    }
    
    @objc dynamic var scheduleStart: Date {
        get {
            return preferences.value(forKey: #function) as? Date
                ?? Calendar.current.date(from: DateComponents(hour: 22))!
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    @objc dynamic var scheduleEnd: Date {
        get {
            return preferences.value(forKey: #function) as? Date
                ?? Calendar.current.date(from: DateComponents(hour: 7))!
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    @objc dynamic var opensAtLogin: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    @objc dynamic var hasLaunchedBefore: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    var location: CLLocation? {
        get {
            return preferences.data(forKey: #function).flatMap { try? NSKeyedUnarchiver
                .unarchivedObject(ofClass: CLLocation.self, from: $0)
            }
        }
        set {
            placemark = nil
            setPreferred(to: newValue.flatMap { try? NSKeyedArchiver
                .archivedData(withRootObject: $0, requiringSecureCoding: true)
            })
        }
    }

    var placemark: String? {
        get {
            return preferences.string(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }

    @objc dynamic var rawSettingsStyle: Int {
        get {
            return preferences.integer(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }

    var settingsStyle: StatusBarItem.Style {
        get {
            return StatusBarItem.Style(rawValue: rawSettingsStyle) ?? .menu
        }
        set {
            rawSettingsStyle = newValue.rawValue
        }
    }

    var toggleShortcutKey: String {
        return "toggleShortcut"
    }
}
