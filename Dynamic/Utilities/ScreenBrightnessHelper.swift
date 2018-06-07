//
//  ScreenBrightnessHelper.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/7/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa
import os.log

extension NSScreen {
    // https://stackoverflow.com/questions/3239749/programmatically-change-mac-display-brightness
    static var brightness: Float {
        var iterator: io_iterator_t = 0
        let gotService = IOServiceGetMatchingServices(
            kIOMasterPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard gotService == kIOReturnSuccess else {
            // os_log("Connection Failed", log: .default, type: .error)
            // return []
            fatalError("Connection Failed")
        }
        // var brightnesses = [Float]()
        var display: io_object_t = 0
        var brightness: Float = 0
        while true {
            display = IOIteratorNext(iterator)
            guard display != 0 else {
                fatalError("No Display")
                // return brightnesses
            }
            IODisplayGetFloatParameter(
                display, 0, kIODisplayBrightnessKey as CFString, &brightness
            )
            // brightnesses.append(brightness)
            IOObjectRelease(display)
            return brightness
        }
    }
}
