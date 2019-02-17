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

public typealias Handler<T> = (T) -> Void
public typealias CompletionHandler = () -> Void

// MARK: - Error Handling

struct AnError: LocalizedError {
    let errorDescription: String?
}

public func remindReportingBug(info: NSDictionary?, title: String? = nil) {
    guard let error = info else { return }
    remindReportingBug(error.reduce("") {
        "\($0)\($1.key): \($1.value)\n"
    }, title: title)
}

public func remindReportingBug(_ text: String, title: String? = nil) {
    let title = title ?? NSLocalizedString(
        "Bug.general.title",
        value: "Report Bug To Developer",
        comment: "Scare the user so they report bugs."
    )
    log(.fault, "BUG: %{public}s", text)
    sendNotification(.reportBug, title: title, subtitle: text) {
        guard $0 != nil else { return }
        runModal(ofNSAlert: { alert in
            alert.alertStyle = .critical
            alert.messageText = title
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

// MARK: - Logging

import os.log

func log(_ type: OSLogType = .default, log: OSLog = .default,
         _ message: StaticString, _ arg: CVarArg? = nil) {
    if let arg = arg {
        os_log(type, log: log, message, arg)
    } else {
        os_log(type, log: log, message)
    }
    #if DEBUG
    let content: String
    if let arg = arg {
        content = String(format: "\(message)", arg)
    } else {
        content = "\(message)"
    }
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
        @unknown default:
            return "CLAuthorizationStatus.\(self.rawValue)"
        }
    }
}

// MARK: - Notification

import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping Handler<UNNotificationPresentationOptions>
    ) { completionHandler(.alert) }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping CompletionHandler) {
        defer { completionHandler() }
        let id = response.notification.request.identifier
        switch NotificationIdentifier(rawValue: id)! {
        case .useCache:
            break
        case .reportBug:
            NSWorkspace.shared.open(URL(string:
                "https://github.com/ApolloZhu/Dynamic-Dark-Mode/issues/new"
            )!)
        }
    }
}

extension AnError {
    static let notificationNotAuthorized = AnError(errorDescription:
        LocalizedString.Notification.notAuthorized
    )
}

enum NotificationIdentifier: String {
    case useCache = "Scheduler.location.useCache"
    case reportBug = "io.github.apollozhu.Dynamic.bug"
}

func sendNotification(_ identifier: NotificationIdentifier, title: String, subtitle: String,
                      then handle: (Handler<Error?>)? = nil) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert]) { authorized, _ in
        guard authorized else {
            handle?(AnError.notificationNotAuthorized);return
        }
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                handle?(AnError.notificationNotAuthorized);return
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            let request = UNNotificationRequest(
                identifier: identifier.rawValue,
                content: content,
                trigger: nil
            )
            center.add(request, withCompletionHandler: handle)
        }
    }
}

func removeAllNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
}
