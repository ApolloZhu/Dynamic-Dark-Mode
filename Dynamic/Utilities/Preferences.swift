//
//  Preferences.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Foundation
import ServiceManagement

enum Preferences {
    private static let preferences = UserDefaults.standard
    
    private static func setPreferred(to value: Any, forKey key: String = #function) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

extension Preferences {
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
