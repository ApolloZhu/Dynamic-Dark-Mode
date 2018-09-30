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

    private func requestLocationUpdate() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .notDetermined:
            manager.stopUpdatingLocation()
            if #available(OSX 10.14, *) {
                manager.requestLocation()
            } else {
                manager.startUpdatingLocation()
            }
            return true
        default:
            return false
        }
    }

    private var isScheduling = false
    public func schedule() {
        if isScheduling { return }
        isScheduling = true
        if !requestLocationUpdate() {
            scheduleAtCachedLocation()
        }
    }

    public typealias StyleProcessor = (AppleInterfaceStyle?) -> Void
    private var _callback: StyleProcessor?
    private var callback: StyleProcessor? {
        get {
            defer { _callback = nil }
            return _callback
        }
        set {
            _callback = newValue
        }
    }
    public func getCurrentMode(then process: @escaping StyleProcessor) {
        callback = process
        if requestLocationUpdate() { return }
        callback?(nil)
    }

    private var task: Task?

    public func mode(atLocation coordinate: CLLocationCoordinate2D?) -> (style: AppleInterfaceStyle, date: Date?) {
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        if let coordinate = coordinate
            , CLLocationCoordinate2DIsValid(coordinate)
            , preferences.scheduleZenithType != .custom {
            let scheduledDate: Date
            let solar = Solar(for: now, coordinate: coordinate)!
            let dates = solar.sunriseSunsetTime
            if now < dates.sunrise {
                scheduledDate = dates.sunrise
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
                let pastSolar = Solar(for: yesterday, coordinate: coordinate)!
                preferences.scheduleStart = pastSolar.sunriseSunsetTime.sunset
                preferences.scheduleEnd = scheduledDate
                return (.darkAqua, scheduledDate)
            } else {
                let futureSolar = Solar(for: tomorrow, coordinate: coordinate)!
                let futureDates = futureSolar.sunriseSunsetTime
                if now < dates.sunset {
                    scheduledDate = dates.sunset
                    preferences.scheduleStart = scheduledDate
                    preferences.scheduleEnd = futureDates.sunrise
                    return (.aqua, scheduledDate)
                } else { // after sunset
                    preferences.scheduleStart = dates.sunset
                    scheduledDate = futureDates.sunrise
                    preferences.scheduleEnd = scheduledDate
                    return (.darkAqua, scheduledDate)
                }
            }
        }
        if preferences.scheduleZenithType != .custom {
            preferences.scheduleZenithType = .custom
        }
        let current = Calendar.current.dateComponents([.hour, .minute], from: now)
        let start = Calendar.current.dateComponents(
            [.hour, .minute], from: preferences.scheduleStart
        )
        let end = Calendar.current.dateComponents(
            [.hour, .minute], from: preferences.scheduleEnd
        )
        if start == end { return (.current, nil) }
        if current < end {
            return (.darkAqua, Calendar.current.date(
                bySettingHour: end.hour!, minute: end.minute!, second: 0, of: now
            ))
        } else if current < start {
            return (.aqua, Calendar.current.date(
                bySettingHour: start.hour!, minute: start.minute!, second: 0, of: now
            ))
        } else if start > end {
            return (.darkAqua, Calendar.current.date(
                bySettingHour: end.hour!, minute: end.minute!, second: 0, of: tomorrow
            ))
        } else {
            return (.aqua, Calendar.current.date(
                bySettingHour: start.hour!, minute: start.minute!, second: 0, of: tomorrow
            ))
        }
    }

    private func schedule(atLocation coordinate: CLLocationCoordinate2D?) {
        defer { isScheduling = false }
        removeAllNotifications()
        let decision = mode(atLocation: coordinate)
        AppleScript.checkPermission(onSuccess: decision.style.enable)
        guard let date = decision.date else { return }
        task = Plan.at(date).do(onElapse: schedule)
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
            log(.info, "Dynamic - Can't Access Location")
            scheduleAtCachedLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        let coordinate = location.coordinate
        if isScheduling {
            schedule(atLocation: coordinate)
        } else {
            callback?(mode(atLocation: coordinate).style)
        }
    }

    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        guard !scheduleAtCachedLocation() else { return }
        runModal(ofNSAlert: { alert in
            alert.messageText = LocalizedString.Location.notAvailable
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
        })
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
    }
}

extension Scheduler: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) { completionHandler(.alert) }
}

func removeAllNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
}
