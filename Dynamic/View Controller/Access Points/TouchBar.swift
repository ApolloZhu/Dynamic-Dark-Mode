//
//  TouchBar.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

enum TouchBar {
    private static let itemID = NSTouchBarItem.Identifier(rawValue: "io.github.apollozhu.Dynamic.switch")
    
    private static let item: NSTouchBarItem = {
        let item = NSCustomTouchBarItem(identifier: itemID)
        let button = NSButton(image: #imageLiteral(resourceName: "Icon"),
                              target: Action.self,
                              action: #selector(Action.perform))
        item.view = button
        return item
    }()
    
    private class Action {
        @objc fileprivate static func perform() {
            if #available(OSX 10.15, *), preferences.AppleInterfaceStyleSwitchesAutomatically {
                reopen()
            } else {
                AppleInterfaceStyle.toggle()
            }
        }
    }
    
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
