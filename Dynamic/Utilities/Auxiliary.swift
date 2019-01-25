//
//  Auxiliary.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/28/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

enum Sandbox {
    public static var isOn: Bool {
        let env = ProcessInfo.processInfo.environment
        return env.keys.contains("APP_SANDBOX_CONTAINER_ID")
    }
}

// MARK: - Error Handling

struct AnError: LocalizedError {
    let errorDescription: String?
}

public func showError(_ info: NSDictionary?, title: String? = nil) {
    guard let error = info else { return }
    showCriticalErrorMessage(error.reduce("") {
        "\($0)\($1.key): \($1.value)\n"
    }, title: title)
}

public func showCriticalErrorMessage(_ text: String, title: String? = nil) {
    runModal(ofNSAlert: { alert in
        alert.alertStyle = .critical
        alert.messageText = title ?? NSLocalizedString(
            "Bug.general.title",
            value: "Report Critical Bug To Developer",
            comment: "Scare the user so they report bugs."
        )
        alert.informativeText = text
    })
}

public func runModal(
    ofNSAlert configure: @escaping (NSAlert) -> Void,
    then process: @escaping (NSApplication.ModalResponse) -> Void = { _ in }
) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        configure(alert)
        process(alert.runModal())
    }
}

// MARK: - Logging

import os.log

func log(_ type: OSLogType = .default, log: OSLog = .default,
         _ message: StaticString, _ args: CVarArg...) {
    os_log(type, log: log, message, args)
    #if DEBUG
    let content = String(format: "\(message)", args)
    if type == .fault {
        fatalError(content)
    } else {
        print(content)
    }
    #endif
}

import CoreLocation

extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined:
            return "CLAuthorizationStatus.notDetermined"
        case .restricted:
            return "CLAuthorizationStatus.restricted"
        case .denied:
            return "CLAuthorizationStatus.denied"
        case .authorizedAlways:
            return "CLAuthorizationStatus.authorizedAlways"
        }
    }
}
