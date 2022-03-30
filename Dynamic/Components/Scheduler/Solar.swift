//
//  Solar.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 11/17/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import CoreLocation

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

struct Solar {
    let date: Date
    let coordinate: CLLocationCoordinate2D
    
    init?(for date: Date, coordinate: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return nil
        }
        self.date = date
        self.coordinate = coordinate
    }
    
    var sunriseSunsetTime: (sunrise: Date, sunset: Date) {
        switch preferences.scheduleZenithType {
        case .custom, .system:
            fatalError("No custom zenith type in solar")
        case .official:
            return NTSolar.sunRiseAndSet(forDate: date,
                                         ofKind: .official,
                                         atLocation: coordinate,
                                         inTimeZone: .current)!
        case .civil:
            return NTSolar.sunRiseAndSet(forDate: date,
                                         ofKind: .civil,
                                         atLocation: coordinate,
                                         inTimeZone: .current)!
        case .nautical:
            return NTSolar.sunRiseAndSet(forDate: date,
                                         ofKind: .nautical,
                                         atLocation: coordinate,
                                         inTimeZone: .current)!
        case .astronomical:
            return NTSolar.sunRiseAndSet(forDate: date,
                                         ofKind: .astronomical,
                                         atLocation: coordinate,
                                         inTimeZone: .current)!
        }
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        return lhs.hour! < rhs.hour!
            || lhs.hour! == rhs.hour! && lhs.minute! < rhs.minute!
    }
}

