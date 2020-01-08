//
//  Notification.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 2/17/19.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import Foundation
import UserNotifications

enum UserNotification {
    enum Identifier: RawRepresentable {
        case useCache
        case reportBug
        case issue(id: Int)
        
        init?(rawValue: String) {
            switch rawValue {
            case "Scheduler.location.useCache": self = .useCache
            case "issues.new": self = .reportBug
            default:
                guard let last = rawValue.split(separator: ".").last
                    , let id = Int(last)
                    else { return nil }
                self = .issue(id: id)
            }
        }
        
        var rawValue: String {
            switch self {
            case .useCache: return "Scheduler.location.useCache"
            case .reportBug: return "issues.new"
            case .issue(let id): return "issues.\(id)"
            }
        }
    }
    
    static func send(_ identifier: UserNotification.Identifier,
                     title: String, subtitle: String,
                     then handle: Handler<Error?>? = nil) {
        var identifier = identifier
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { _,_ in
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else {
                    handle?(AnError.notificationNotAuthorized);return
                }
                let content = UNMutableNotificationContent()
                content.title = title
                content.subtitle = subtitle
                if title.contains("-1751") || subtitle.contains("-1751") {
                    identifier = .issue(id: 18) // annoying and hard to reproduce
                } // I don't know where that -1751 is from, but I'll catch u
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
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        let id = response.notification.request.identifier
        switch UserNotification.Identifier(rawValue: id)! {
        case .useCache:
            break
        case .reportBug:
            openURL("https://github.com/ApolloZhu/Dynamic-Dark-Mode/issues/new")
        case .issue(let id):
            openURL("https://github.com/ApolloZhu/Dynamic-Dark-Mode/issues/\(id)")
        }
    }
}

extension AnError {
    static let notificationNotAuthorized = AnError(errorDescription:
        LocalizedString.Notification.notAuthorized
    )
}
