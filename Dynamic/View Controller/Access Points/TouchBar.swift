//
//  TouchBar.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

enum TouchBar {
    private static let itemID = NSTouchBarItem.Identifier(rawValue: "io.github.apollozhu.Dynamic.switch")
    
    private static let item: NSTouchBarItem = {
        let item = NSCustomTouchBarItem(identifier: itemID)
        let button = NSButton(image: #imageLiteral(resourceName: "Icon"),
                              target: AppleInterfaceStyle.Coordinator,
                              action: #selector(AppleInterfaceStyleCoordinator.toggleOrShowInterface))
        item.view = button
        return item
    }()
    
    public static func setup() {
        // DFRSystemModalShowsCloseBoxWhenFrontMost(false)
        NSTouchBarItem.addSystemTrayItem(item)
    }
    
    public static func tearDown() {
        NSTouchBarItem.removeSystemTrayItem(item)
    }
    
    public static func show() {
        DFRElementSetControlStripPresenceForIdentifier(itemID, true)
    }
    
    public static func hide() {
        DFRElementSetControlStripPresenceForIdentifier(itemID, false)
    }
}
