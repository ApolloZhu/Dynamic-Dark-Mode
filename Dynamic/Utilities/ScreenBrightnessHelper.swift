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
    /**
     Reads and returns the brightness of the "main" display.
     
     - Todo:
     Haven't figured out how to identify main display through IOKit yet,
     but Core Graphics can get serial and vendor number through CGDisplay.
     
     - Note:
     https://stackoverflow.com/questions/3239749/programmatically-change-mac-display-brightness
     */
    static var brightness: Float {
        var iterator: io_iterator_t = 0
        let gotService = IOServiceGetMatchingServices(
            kIOMasterPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard gotService == kIOReturnSuccess else {
            // os_log("Connection Failed", log: .default, type: .error)
            fatalError("Connection Failed")
        }
        while true {
            let display: io_object_t = IOIteratorNext(iterator)
            guard display != 0 else {
                fatalError("No Display") // Or end of all displays
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
