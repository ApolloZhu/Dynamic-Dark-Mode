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
            comment: "AutoAdjustThreshold"
        )
        static let scheduleMode = NSLocalizedString(
            "SettingsViewController.ScheduleMode",
            comment: "ScheduleMode"
        )
    }
    enum SunsetSunrise {
        static let official = NSLocalizedString(
            "SunsetSunrise.Official",
            comment: "Official"
        )
        static let civil = NSLocalizedString(
            "SunsetSunrise.Civil",
            comment: "Civil"
        )
        static let nautical = NSLocalizedString(
            "SunsetSunrise.Nautical",
            comment: "Nautical"
        )
        static let astronomical = NSLocalizedString(
            "SunsetSunrise.Astronomical",
            comment: "Astronomical"
        )
        static let customRange = NSLocalizedString(
            "SunsetSunrise.CustomRange",
            comment: "CustomRange"
        )
    }
    enum Location {
        static let notAvailable = NSLocalizedString(
            "Location.notAvailable",
            comment: "Failed to attain user location for sunset/sunrise calculation."
        )
        static let useCache = NSLocalizedString(
            "Location.useCache",
            comment: "Can't fetch user's current location. Using cache instead."
        )
    }
}
