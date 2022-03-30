//
//  Solar.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 11/17/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import Solar

public enum Zenith: Int {
    case official
    case civil
    case nautical
    case astronomical
    case custom
    @available(macOS 10.15, *)
    case system
}

extension Zenith {
    static let hasZenithTypeSystem: Bool = {
        if #available(macOS 10.15, *) {
            return true
        }
        return false
    }()
    
    var hasSunriseSunsetTime: Bool {
        switch self {
        case .official, .civil, .nautical, .astronomical:
            return true
        case .custom, .system:
            return false
        }
    }
}

extension Solar {
    var sunriseSunsetTime: (sunrise: Date, sunset: Date) {
        switch preferences.scheduleZenithType {
        case .custom, .system:
            fatalError("No custom zenith type in solar")
        case .official:
            return (sunrise!, sunset!)
        case .civil:
            return (civilSunrise!, civilSunset!)
        case .nautical:
            return (nauticalSunrise!, nauticalSunset!)
        case .astronomical:
            return (astronomicalSunrise!, astronomicalSunset!)
        }
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        return lhs.hour! < rhs.hour!
            || lhs.hour! == rhs.hour! && lhs.minute! < rhs.minute!
    }
}

