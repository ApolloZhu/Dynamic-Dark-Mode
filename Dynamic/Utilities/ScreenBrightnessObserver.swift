//
//  ScreenBrightnessObserver.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/8/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

func loadPrivateFramework(named name: String) {
    dlopen("/System/Library/PrivateFrameworks/\(name).framework/\(name)", RTLD_NOW)
}
