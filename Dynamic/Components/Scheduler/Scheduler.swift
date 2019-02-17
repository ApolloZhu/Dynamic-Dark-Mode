//
//  Scheduler.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/13/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import CoreLocation
import UserNotifications
import Solar
import Schedule

public final class Scheduler: NSObject {
    public static let shared = Scheduler()
    
    private weak var task: Task?
    
    public func cancel() {
        task?.cancel()
        task = nil
    }
    
    @objc public func schedule(enableCurrentStyle: Bool = true) {
        func processLocation(_ result: Location) {
            switch result {
            case .current(let location):
                scheduleAtLocation(location, enableCurrentStyle: enableCurrentStyle)
            case .cached(let location):
                scheduleAtCachedLocation(location, enableCurrentStyle: enableCurrentStyle)
            case .failed(let error):
                Location.alertNotAvailable(dueTo: error)
            }
        }
        LocationManager.serial.fetch(then: processLocation)
    }
    
    private func scheduleAtLocation(_ location: CLLocation?,
                                    enableCurrentStyle: Bool) {
        UserNotification.removeAll()
        let decision = mode(atLocation: location?.coordinate)
        if enableCurrentStyle {
            AppleScript.checkPermission(onSuccess: decision.style.enable)
        }
        guard let date = decision.date else { return }
        cancel()
        task = Plan.at(date).do { [weak self] in self?.schedule() }
    }
    
    @discardableResult
    private func scheduleAtCachedLocation(_ location: CLLocation,
                                          enableCurrentStyle: Bool) -> Bool {
        guard preferences.scheduleZenithType != .custom else {
            scheduleAtLocation(nil, enableCurrentStyle: enableCurrentStyle)
            return false
        }
        UserNotification.removeAll()
        UserNotification.send(.useCache,
                              title: LocalizedString.Location.useCache,
                              subtitle: preferences.placemark ??
                                String(format:"<%.2f,%.2f>",
                                       location.coordinate.latitude,
                                       location.coordinate.longitude))
        scheduleAtLocation(location, enableCurrentStyle: enableCurrentStyle)
        return true
    }
    
    // Mark: - Mode
    
    public func getCurrentMode(then process: @escaping Handler<Result<Mode, Error>>) {
        LocationManager.serial.fetch { [unowned self] in
            switch $0 {
            case .current(let location), .cached(let location):
                process(.success(self.mode(atLocation: location.coordinate)))
            case .failed(let error):
                process(.failure(error))
            }
        }
    }
    
    public typealias Mode = (style: AppleInterfaceStyle, date: Date?)
    
    public func mode(atLocation coordinate: CLLocationCoordinate2D?) -> Mode {
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
    
    // MARK: - Missed Schedule
    
    private override init() {
        super.init()
        for name in [NSWorkspace.didWakeNotification,
                     NSWorkspace.screensDidWakeNotification,
                     NSWorkspace.sessionDidBecomeActiveNotification] {
            NSWorkspace.shared.notificationCenter.addObserver(
                self, selector: #selector(workspaceDidWake),
                name: name, object: nil
            )
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(schedule),
            name: Notification.Name.NSSystemClockDidChange,
            object: nil
        )
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func workspaceDidWake() {
        if let task = task,
            !task.restOfLifetime.isPositive,
             task.countOfExecutions < 1 {
            task.execute()
            cancel()
        } else if preferences.scheduled {
            schedule()
        }
    }
}
