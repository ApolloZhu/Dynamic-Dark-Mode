//
//  Notification.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 2/17/19.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import Foundation
import UserNotifications

enum UserNotification {
    enum Identifier: String {
        case useCache = "Scheduler.location.useCache"
        case reportBug = "io.github.apollozhu.Dynamic.bug"
    }
    
    static func send(_ identifier: UserNotification.Identifier,
                     title: String, subtitle: String,
                     then handle: Handler<Error?>? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { _,_ in
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
    
    static func removeAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping Handler<UNNotificationPresentationOptions>) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping CompletionHandler) {
        defer { completionHandler() }
        let id = response.notification.request.identifier
        switch UserNotification.Identifier(rawValue: id)! {
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
