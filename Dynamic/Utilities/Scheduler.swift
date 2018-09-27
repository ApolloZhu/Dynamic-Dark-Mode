//
//  Scheduler.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/13/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import CoreLocation
import UserNotifications
import Solar
import Schedule
import os.log

public final class Scheduler: NSObject, CLLocationManagerDelegate {
    public static let shared = Scheduler()
    private override init() { super.init() }

    private var isScheduling = false
    public func schedule() {
        if isScheduling { return }
        isScheduling = true
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .notDetermined:
            manager.stopUpdatingLocation()
            if #available(OSX 10.14, *) {
                manager.requestLocation()
            } else {
                manager.startUpdatingLocation()
            }
        default:
            scheduleAtCachedLocation()
        }
    }

    private var task: Task?

    private func schedule(atLocation coordinate: CLLocationCoordinate2D?) {
        defer { isScheduling = false }
        guard preferences.scheduled else { return cancel() }
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        if let coordinate = coordinate
            , CLLocationCoordinate2DIsValid(coordinate)
            , preferences.scheduleZenithType != .custom {
            let scheduledDate: Date
            let solar = Solar(for: now, coordinate: coordinate)!
            let dates = solar.sunriseSunsetTime
            #warning("FIXME: Having trouble figuring out time zone")
            if now < dates.sunrise {
                AppleInterfaceStyle.darkAqua.enable()
                scheduledDate = dates.sunrise
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
                let pastSolar = Solar(for: yesterday, coordinate: coordinate)!
                preferences.scheduleStart = pastSolar.sunriseSunsetTime.sunset
                preferences.scheduleEnd = scheduledDate
            } else {
                let futureSolar = Solar(for: tomorrow, coordinate: coordinate)!
                let futureDates = futureSolar.sunriseSunsetTime
                if now < dates.sunset {
                    AppleInterfaceStyle.aqua.enable()
                    scheduledDate = dates.sunset
                    preferences.scheduleStart = scheduledDate
                    preferences.scheduleEnd = futureDates.sunrise
                } else { // after sunset
                    AppleInterfaceStyle.darkAqua.enable()
                    preferences.scheduleStart = dates.sunset
                    scheduledDate = futureDates.sunrise
                    preferences.scheduleEnd = scheduledDate
                }
            }
            return task = Plan.at(scheduledDate).do(onElapse: schedule)
        }
        if preferences.scheduleZenithType != .custom {
            preferences.scheduleZenithType = .custom
        }
        #warning("FIXME: This is gonna be a catastrophe when a user moves across timezone")
        let current = Calendar.current.dateComponents([.hour, .minute], from: now)
        let start = Calendar.current.dateComponents(
            [.hour, .minute], from: preferences.scheduleStart
        )
        let end = Calendar.current.dateComponents(
            [.hour, .minute], from: preferences.scheduleEnd
        )
        let scheduledDate: Date!
        if current < end {
            AppleInterfaceStyle.darkAqua.enable()
            scheduledDate = Calendar.current.date(
                bySettingHour: end.hour!, minute: end.minute!, second: 0, of: now
            )
        } else if current < start {
            AppleInterfaceStyle.aqua.enable()
            scheduledDate = Calendar.current.date(
                bySettingHour: start.hour!, minute: start.minute!, second: 0, of: now
            )
        } else {
            AppleInterfaceStyle.darkAqua.enable()
            scheduledDate = Calendar.current.date(
                bySettingHour: end.hour!, minute: end.minute!, second: 0, of: tomorrow
            )
        }
        task = Plan.at(scheduledDate).do(onElapse: schedule)
    }

    public func cancel() {
        task?.cancel()
    }

    // MARK: - Real World

    private lazy var manager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways {
            #if DEBUG
            print("Denied Location Access")
            #else
            os_log(.fault, "Dynamic - Can't Access Location")
            #endif
            scheduleAtCachedLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        schedule(atLocation: location.coordinate)
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        if !scheduleAtCachedLocation() {
            let alert = NSAlert()
            alert.messageText = LocalizedString.Location.notAvailable
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
    }

    @discardableResult
    private func scheduleAtCachedLocation() -> Bool {
        guard let location = preferences.location
            , preferences.scheduleZenithType != .custom
            else {
            schedule(atLocation: nil)
            return false
        }
        if let name = preferences.placemark {
            notifyUsingPlacemark(named: name)
        } else {
            CLGeocoder().reverseGeocodeLocation(location)
            { [weak self] placemarks, _ in
                guard let name = placemarks?.first?.name else { return }
                preferences.placemark = name
                self?.notifyUsingPlacemark(named: name)
            }
        }
        schedule(atLocation: location.coordinate)
        return true
    }
}

public enum Zenith: Int, CaseIterable {
    case official
    case civil
    case nautical
    case astronomical
    case custom
}

extension Solar {
    fileprivate var sunriseSunsetTime: (sunrise: Date, sunset: Date) {
        switch preferences.scheduleZenithType {
        case .custom:
            fatalError("No custom zenith type in solar")
        case .official:
            return (sunrise!, sunset!)
        case .civil:
            return (civilSunrise!, civilSunset!)
        case .nautical:
            return (nauticalSunrise!, nauticalSunset!)
        case .astronomical:
            return (astronomicalSunrise!, astronomicalSunset!)
        }
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        return lhs.hour! < rhs.hour!
            || lhs.hour! == rhs.hour! && lhs.minute! < rhs.minute!
    }
}

// MARK: - Notification

extension Scheduler {
    private func notifyUsingPlacemark(named name: String) {
        if #available(OSX 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert]) { authorized, _ in
                center.getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    guard authorized else { return }
                    let content = UNMutableNotificationContent()
                    content.title = LocalizedString.Location.useCache
                    content.subtitle = name
                    let request = UNNotificationRequest(
                        identifier: "Scheduler.location.useCache",
                        content: content,
                        trigger: nil
                    )
                    removeAllNotifications()
                    center.add(request)
                }
            }
        } else {
            let center = NSUserNotificationCenter.default
            let notification = NSUserNotification()
            notification.title = LocalizedString.Location.useCache
            notification.subtitle = name
            center.deliver(notification)
        }
    }
}

@available(OSX 10.14, *)
extension Scheduler: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) { completionHandler(.alert) }
}

extension Scheduler: NSUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification
    ) -> Bool { return true }
}

func removeAllNotifications() {
    if #available(OSX 10.14, *) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    } else {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }
}
