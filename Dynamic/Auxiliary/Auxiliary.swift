//
//  Auxiliary.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/28/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

enum Sandbox {
    public static var isOn: Bool {
        let env = ProcessInfo.processInfo.environment
        return env.keys.contains("APP_SANDBOX_CONTAINER_ID")
    }
}

public typealias Handler<T> = (T) -> Void
public typealias CompletionHandler = () -> Void

func openURL(_ string: String) {
    NSWorkspace.shared.open(URL(string: string)!)
}
