//
//  Preferences.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa
import ServiceManagement

enum Sandbox {
    public static var isOn: Bool {
        let env = ProcessInfo.processInfo.environment
        return env.keys.contains("APP_SANDBOX_CONTAINER_ID")
    }
}

enum Preferences {
    private static let preferences = NSUserDefaultsController.shared.defaults
    
    private static func setPreferred(to value: Any?,
                                     forKey key: String = #function) {
        preferences.set(value, forKey: key)
    }
}

extension Preferences {
    static var adjustForBrightness: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
            ScreenBrightnessObserver.shared.stop()
            if newValue {
                ScreenBrightnessObserver.shared.start()
            }
        }
    }
    
    static var brightnessThreshold: Float {
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
    
    static var scheduled: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    static var scheduleType: Scheduler.Zenith {
        get {
            return Scheduler.Zenith(
                rawValue: preferences.integer(forKey: #function)
            ) ?? .official
        }
        set {
            #warning("Todo: Schedule Dark Mode")
            setPreferred(to: newValue.rawValue)
        }
    }
    
    static var scheduleStart: Date? {
        get {
            return preferences.value(forKey: #function) as? Date
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    static var scheduleEnd: Date? {
        get {
            return preferences.value(forKey: #function) as? Date
        }
        set {
            setPreferred(to: newValue)
        }
    }
    
    static var opensAtLogin: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            assert(SMLoginItemSetEnabled(
                "io.github.apollozhu.Dynamic.Launcher" as CFString,
                newValue
            ))
            setPreferred(to: newValue)
        }
    }
    
    static var hasLaunchedBefore: Bool {
        get {
            return preferences.bool(forKey: #function)
        }
        set {
            setPreferred(to: newValue)
        }
    }
}
