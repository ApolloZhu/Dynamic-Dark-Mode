//
//  TouchBar.swift
//  Dynamic Dark Mode
//
//  Created by apollonian on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

enum TouchBar {
    static func setup() {
        #if Masless
        #warning("TODO: Add option to disable displaying toggle button in Control Strip")
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        let identifier = NSTouchBarItem.Identifier(rawValue: "io.github.apollozhu.Dynamic.switch")
        let item = NSCustomTouchBarItem(identifier: identifier)
        #warning("TODO: Redesign icon for toggle button")
        let button = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"),
                              target: AppleInterfaceStyle.coordinator,
                              action: #selector(toggleInterfaceStyle))
        item.view = button
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(identifier, true)
        #endif
    }
}
