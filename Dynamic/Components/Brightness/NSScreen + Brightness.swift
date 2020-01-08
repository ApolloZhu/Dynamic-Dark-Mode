//
//  NSScreen + Brightness.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/7/18.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

extension NSScreen {
    /**
     Reads and returns the brightness of the "main" display.
     
     - Todo:
     Haven't figured out how to identify main display through IOKit yet,
     but Core Graphics can get serial and vendor number through CGDisplay.
     
     - Note:
     https://stackoverflow.com/questions/3239749/programmatically-change-mac-display-brightness
     */
    static var brightness: Float {
        var iterator: io_iterator_t = IO_OBJECT_NULL
        let gotService = IOServiceGetMatchingServices(
            kIOMasterPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard gotService == kIOReturnSuccess else {
            debugPrint("Dynamic Dark Mode - Display Connection Failed")
            return -1
        }
        while true {
            let display: io_object_t = IOIteratorNext(iterator)
            guard display != IO_OBJECT_NULL else {
                debugPrint("Dynamic Dark Mode - No Display Found")
                return -1
            }
            var brightness: Float = 0
            IODisplayGetFloatParameter(
                display, 0, kIODisplayBrightnessKey as CFString, &brightness
            )
            IOObjectRelease(display)
            return brightness
        }
    }
}
