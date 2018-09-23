//
//  Preferences.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import ServiceManagement

enum Sandbox {
    public static var isOn: Bool {
        let env = ProcessInfo.processInfo.environment
        return env.keys.contains("APP_SANDBOX_CONTAINER_ID")
    }
}

/// ~/Library/Preferences/io.github.apollozhu.Dynamic.plist
typealias Preferences = UserDefaults
public let preferences = NSUserDefaultsController.shared.defaults

extension UserDefaults {
    private static var handles: [NSKeyValueObservation] = []

    public static func removeObservers() {
        handles.lazy.forEach { $0.invalidate() }
        handles = []
    }

    public static func setupObservers() {
        removeObservers()
        func observe<Value>(
            _ keyPath: KeyPath<UserDefaults, Value>,
            observeInitial: Bool = false,
            changeHandler: @escaping (NSKeyValueObservedChange<Value>) -> Void
        ) -> NSKeyValueObservation {
            let options: NSKeyValueObservingOptions =
                observeInitial ? [.initial, .new] : [.new]
            return preferences.observe(keyPath, options: options)
            { _, change in changeHandler(change) }
        }
        handles = [
            observe(\.adjustForBrightness, observeInitial: true) { change in
                ScreenBrightnessObserver.shared.stop()
                if change.newValue == true {
                    ScreenBrightnessObserver.shared.start()
                }
            },
            observe(\.scheduled, observeInitial: true) { change in
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
                assert(SMLoginItemSetEnabled(
                    "io.github.apollozhu.Dynamic.Launcher" as CFString,
                    change.newValue ?? true
                ))
            }
        ]
    }

    private func setPreferred(to value: Any?, forKey key: String = #function) {
        (NSUserDefaultsController.shared.values as AnyObject).setValue(value, forKey: "\(key)")
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
}
