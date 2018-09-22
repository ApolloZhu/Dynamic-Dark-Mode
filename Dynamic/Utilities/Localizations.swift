//
//  Localizations.swift
//  Dynamic
//
//  Created by Captain雪ノ下八幡 on 2018/6/18.
//  Copyright © 2018 Dynamic. All rights reserved.
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
        static let astronimical = NSLocalizedString(
            "SunsetSunrise.Astronimical",
            value: "Astronimical",
            comment: "Astronimical"
        )
        static let customRange = NSLocalizedString(
            "SunsetSunrise.CustomRange",
            value: "Custom",
            comment: "CustomRange"
        )
    }
}
