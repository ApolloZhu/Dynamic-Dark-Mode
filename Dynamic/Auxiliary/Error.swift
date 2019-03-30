//
//  Error.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 2/17/19.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

struct AnError: LocalizedError {
    let errorDescription: String?
}

public func remindReportingBug(info: NSDictionary?, title: String? = nil) {
    guard let error = info else { return }
    remindReportingBug(error.reduce("") {
        "\($0)\($1.key): \($1.value)\n"
    }, title: title)
}

public func remindReportingBug(_ text: String, title: String? = nil, issueID: Int? = nil) {
    let heading: String
    let notification: UserNotification.Identifier
    if let id = issueID {
        log(.error, "Dynamic Dark Mode BUG: #%{public}d", id)
        notification = .issue(id: id)
        heading = title ?? NSLocalizedString(
            "Bug.known.title",
            value: "Encountered a Known Issue",
            comment: "Request users to provide more context."
        )
    } else {
        log(.fault, "Dynamic Dark Mode BUG: %{public}s", text)
        notification = .reportBug
        heading = title ?? NSLocalizedString(
            "Bug.general.title",
            value: "Report Bug To Developer",
            comment: "Scare the user so they report bugs."
        )
    }
    UserNotification.send(notification, title: heading, subtitle: text) { error in
        guard error != nil else { return }
        runModal(ofNSAlert: { alert in
            alert.alertStyle = .critical
            alert.messageText = heading
            alert.informativeText = text
        })
    }
}

public func runModal(
    ofNSAlert configure: @escaping Handler<NSAlert>,
    then process: @escaping Handler<NSApplication.ModalResponse> = { _ in }
) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        configure(alert)
        process(alert.runModal())
    }
}

// MARK: - Silent Errors

import os.log

func log(_ type: OSLogType = .default, log: OSLog = .default,
         _ message: StaticString, _ arg: CVarArg? = nil) {
    if let arg = arg {
        os_log(type, log: log, message, arg)
    } else {
        os_log(type, log: log, message)
    }
    #if DEBUG
    let content = arg.map { String(format: "\(message)", $0) } ?? "\(message)"
    if type == .fault {
        fatalError(content)
    } else {
        print(content)
    }
    #endif
}
