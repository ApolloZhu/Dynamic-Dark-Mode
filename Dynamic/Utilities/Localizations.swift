//
//  Localizations.swift
//  Dynamic
//
//  Created by Captain雪ノ下八幡 on 2018/6/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Foundation
extension String {
    
    struct Localized {
        
        struct SettingsViewController {

            static let autoAdjustThreshold = NSLocalizedString("Localization.SettingsViewController.AutoAdjustThreshold", comment: "AutoAdjustThreshold")
            static let scheduleMode = NSLocalizedString("Localization.SettingsViewController.ScheduleMode", comment: "ScheduleMode")
            
            static let official = NSLocalizedString("Localization.SettingsViewController.Official", comment: "Official")
            static let civil = NSLocalizedString("Localization.SettingsViewController.Civil", comment: "Civil")
            static let nautical = NSLocalizedString("Localization.SettingsViewController.Nautical", comment: "Nautical")
            static let astronimical = NSLocalizedString("Localization.SettingsViewController.Astronimical", comment: "Astronimical")
            static let customRange = NSLocalizedString("Localization.SettingsViewController.CustomRange", comment: "CustomRange")
            
            private init() {}
        }
        
        private init() {}
    }
    
}
