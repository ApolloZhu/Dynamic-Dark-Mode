//
//  Solar.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 11/17/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Solar

public enum Zenith: Int, CaseIterable {
    case official
    case civil
    case nautical
    case astronomical
    case custom
}

extension Solar {
    var sunriseSunsetTime: (sunrise: Date, sunset: Date) {
        switch preferences.scheduleZenithType {
        case .custom:
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

