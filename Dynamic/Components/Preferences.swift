//
//  Preferences.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import CoreLocation
import ServiceManagement
import MASShortcut

typealias Preferences = UserDefaults
public let preferences = NSUserDefaultsController.shared.defaults

extension Preferences {
    public static func setupAsSuggested() {
        preferences.adjustForBrightness = true
        preferences.brightnessThreshold = 0.5
        preferences.settingsStyle = .menu
        if Location.deniedAccess {
            preferences.scheduleZenithType = .custom
        } else {
            preferences.scheduleZenithType = .official
        }
        preferences.scheduled = true
        setupDefaultsForNewFeatures()
    }
    
    public static func setupDefaultsForNewFeatures() {
        if !preferences.exists(\.disableAdjustForBrightnessWhenScheduledDarkModeOn) {
            preferences.disableAdjustForBrightnessWhenScheduledDarkModeOn = true
        }
        if !preferences.exists(\.showToggleInTouchBar) {
            preferences.showToggleInTouchBar = true
        }
    }
}

extension Preferences {
    private static var handles: [NSKeyValueObservation] = []
    
    public static func stopObserving() {
        StatusBarItem.only.stopObserving()
        handles.forEach { $0.invalidate() }
        handles = []
    }
    
    public static func startObserving() {
        stopObserving()
        StatusBarItem.only.startObserving()
        func observe<Value>(
            _ keyPath: KeyPath<UserDefaults, Value>,
            observeInitial: Bool = false,
            changeHandler: @escaping Handler<NSKeyValueObservedChange<Value>>
        ) -> NSKeyValueObservation {
            let options: NSKeyValueObservingOptions =
                observeInitial ? [.initial, .old, .new] : [.old, .new]
            return preferences.observe(keyPath, options: options)
            { _, change in changeHandler(change) }
        }
        handles = [
            observe(\.adjustForBrightness) { change in
                if change.newValue == true {
                    ScreenBrightnessObserver.shared.startObserving()
                }
            },
            observe(\.disableAdjustForBrightnessWhenScheduledDarkModeOn) { _ in
                AppleInterfaceStyle.Coordinator.setup()
            },
            observe(\.scheduled) { change in
                if change.newValue == true {
                    if #available(OSX 10.15, *), preferences.AppleInterfaceStyleSwitchesAutomatically { return }
                    Scheduler.shared.schedule()
                    Connectivity.default.scheduleWhenReconnected()
                } else {
                    Scheduler.shared.cancel()
                    Connectivity.default.stopObserving()
                }
            },
            observe(\.scheduleType) { change in
                if #available(OSX 10.15, *) {
                    if preferences.scheduleZenithType == .system {
                        if !SLSGetAppearanceThemeSwitchesAutomatically() {
                            SLSSetAppearanceThemeSwitchesAutomatically(true)
                        }
                        preferences.scheduled = true
                        AppleInterfaceStyle.Coordinator.tearDown(stopAppearanceObservation: false)
                    } else {
                        if SLSGetAppearanceThemeSwitchesAutomatically() {
                            SLSSetAppearanceThemeSwitchesAutomatically(false)
                        } else if preferences.scheduled, change.oldValue == Zenith.system.rawValue {
                            return Scheduler.shared.updateSchedule { _ in }
                        }
                    }
                }
                if preferences.scheduled {
                    Scheduler.shared.schedule()
                } // else do nothing
            },
            observe(\.scheduleStart) { _ in
                if preferences.scheduled && !preferences.scheduleZenithType.hasSunriseSunsetTime {
                    Scheduler.shared.schedule()
                }
            },
            observe(\.scheduleEnd) { _ in
                if preferences.scheduled && !preferences.scheduleZenithType.hasSunriseSunsetTime {
                    Scheduler.shared.schedule()
                }
            },
            observe(\.showToggleInTouchBar, observeInitial: true) { change in
                if change.newValue == true {
                    TouchBar.show()
                } else {
                    TouchBar.hide()
                }
            },
            observe(\.opensAtLogin) { change in
                guard !SMLoginItemSetEnabled(
                    "io.github.apollozhu.Dynamic.Launcher" as CFString,
                    change.newValue ?? true
                ) else { return }
                remindReportingBug(NSLocalizedString(
                    "Preferences.opensAtLogin.failed",
                    value: "Failed to update \"opens at login\" settings",
                    comment: "Indicates either enable or disable opens at login failed."
                ), issueID: 40)
            }
        ]
        if #available(OSX 10.15, *) {
            handles.append(observe(\.AppleInterfaceStyleSwitchesAutomatically) { (change) in
                if change.newValue == true {
                    preferences.scheduleZenithType = .system
                    ScreenBrightnessObserver.shared.stopObserving()
                    Shortcut.stopObserving()
                } else {
                    Shortcut.startObserving()
                    if preferences.scheduleZenithType == .system {
                        preferences.scheduleZenithType = .official
                    }
                }
            })
        }
    }
}

extension Preferences {
    func setPreferred(to value: Any?, forKey key: String = #function) {
        (NSUserDefaultsController.shared.values as AnyObject)
            .setValue(value, forKey: "\(key)")
    }
    
    func exists(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    func exists<T>(_ keyPath: KeyPath<Preferences, T>) -> Bool {
        guard let key = keyPath._kvcKeyPathString else {
            #if DEBUG
            fatalError("No key path string")
            #else
            return false
            #endif
        }
        return exists(key)
    }
    
    @objc dynamic var adjustForBrightness: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    @objc dynamic var disableAdjustForBrightnessWhenScheduledDarkModeOn: Bool {
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
                return Float(raw / 100)
            } else {
                setPreferred(to: 50.0)
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
    
    @objc private dynamic var scheduleType: Int {
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
    
    @objc dynamic var showToggleInTouchBar: Bool {
        get {
            return preferences.bool(forKey: #function)
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
    
    @objc dynamic var lightDesktopURL: URL? {
        get {
            return preferences.string(forKey: #function).flatMap(URL.init(string:))
        }
        set {
            setPreferred(to: newValue?.absoluteString)
        }
    }
    
    @objc dynamic var darkDesktopURL: URL? {
        get {
            return preferences.string(forKey: #function).flatMap(URL.init(string:))
        }
        set {
            setPreferred(to: newValue?.absoluteString)
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
    
    static let toggleShortcutKey: String = "toggleShortcut"
    
    @available(macOS 10.15, *)
    @objc dynamic var AppleInterfaceStyleSwitchesAutomatically: Bool {
        return preferences.bool(forKey: #function)
    }
}
