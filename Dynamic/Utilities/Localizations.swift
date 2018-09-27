//
//  Localizations.swift
//  Dynamic
//
//  Created by Captain雪ノ下八幡 on 2018/6/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Foundation

enum LocalizedString {
    enum SettingsViewController {
        static let autoAdjustThreshold = NSLocalizedString(
            "SettingsViewController.AutoAdjustThreshold",
            value: "Auto Adjust Threshold",
            comment: "AutoAdjustThreshold"
        )
        static let scheduleMode = NSLocalizedString(
            "SettingsViewController.ScheduleMode",
            value: "Schedule Mode",
            comment: "ScheduleMode"
        )
    }
    enum SunsetSunrise {
        static let official = NSLocalizedString(
            "SunsetSunrise.Official",
            value: "Official",
            comment: "Official"
        )
        static let civil = NSLocalizedString(
            "SunsetSunrise.Civil",
            value: "Civil",
            comment: "Civil"
        )
        static let nautical = NSLocalizedString(
            "SunsetSunrise.Nautical",
            value: "Nautical",
            comment: "Nautical"
        )
        static let astronomical = NSLocalizedString(
            "SunsetSunrise.Astronomical",
            value: "Astronomical",
            comment: "Astronomical"
        )
        static let customRange = NSLocalizedString(
            "SunsetSunrise.CustomRange",
            value: "Custom",
            comment: "CustomRange"
        )
    }
    enum Location {
        static let notAvailable = NSLocalizedString(
            "Location.notAvailable",
            value: "Location Service Unavailable",
            comment: "Failed to attain user location for sunset/sunrise calculation."
        )
        static let useCache = NSLocalizedString(
            "Location.useCache",
            value: "Scheduled Using Previous Location",
            comment: "Can't fetch user's current location. Using cache instead."
        )
    }
}
