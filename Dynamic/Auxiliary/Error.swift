//
//  Error.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 2/17/19.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

struct AnError: LocalizedError {
    let errorDescription: String?
}

public func remindReportingBug(_ text: String, title: String? = nil, issueID: Int? = nil) {
    let heading: String
    let notification: UserNotification.Identifier
    if let id = issueID {
        notification = .issue(id: id)
        heading = title ?? NSLocalizedString(
            "Bug.known.title",
            value: "Encountered a Known Issue",
            comment: "Request users to provide more context."
        )
    } else {
        notification = .reportBug
        heading = title ?? NSLocalizedString(
            "Bug.general.title",
            value: "Report Bug To Developer",
            comment: "Scare the user so they report bugs."
        )
    }
    debugPrint(heading + (issueID.map { " #\($0)" } ?? ""))
    debugPrint(text)
    UserNotification.send(notification, title: heading, subtitle: text) { error in
        guard error != nil else { return }
        showAlert(withConfiguration: { alert in
            alert.alertStyle = .critical
            alert.messageText = heading
            alert.informativeText = text
        })
    }
}

public func showAlert(
    withConfiguration configure: @escaping Handler<NSAlert>,
    then process: @escaping Handler<NSApplication.ModalResponse> = { _ in }
) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        configure(alert)
        process(alert.runModal())
    }
}
