//
//  Location.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 11/17/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import CoreLocation
import Schedule

public enum Location {
    case current(CLLocation)
    case cached(CLLocation)
    case failed(Error)
    
    public typealias Processor = (Location) -> Void
}

extension Location {
    static var deniedAccess: Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .notDetermined:
            return false
        case .denied, .restricted:
            return true
        @unknown default:
            remindReportingBug(status.description)
            return false
        }
    }
    
    static var allowsAccess: Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        @unknown default:
            remindReportingBug(status.description)
            return false
        }
    }
}

extension CLError {
    static let nsDenied = NSError(
        domain: CLError.errorDomain,
        code: CLError.Code.denied.rawValue,
        userInfo: nil
    )
    static let denied = CLError(_nsError: nsDenied)
}

func ==(lhs: Error?, rhs: CLError) -> Bool {
    return CLError.nsDenied.isEqual(to: lhs)
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private var lock = NSLock()
    
    private var retryCount = 5
    private let timeout = Interval(seconds: 4)
    private var callbacks: [(id: UUID, process: Location.Processor, onTimeout: Task)] = [] {
        didSet {
            if callbacks.isEmpty {
                manager.stopUpdatingLocation()
            }
        }
    }
    private func callback(_ location: Location) {
        lock.lock()
        defer { lock.unlock() }
        guard !callbacks.isEmpty else { return }
        callbacks.removeFirst().process(location)
        retryCount = 5
    }
    
    public weak var delegate: CLLocationManagerDelegate?
    
    public func fetch(then processor: @escaping Location.Processor) {
        lock.lock()
        let id = UUID()
        let task = Plan.after(timeout).do(onElapse: onTimeout)
        task.addTag(id.uuidString)
        callbacks.append((id, processor, task))
        lock.unlock()
        startUpdatingLocation()
    }
    
    private func onTimeout(_ task: Task) {
        lock.lock()
        callbacks.removeAll {
            guard task.tags.contains($0.id.uuidString)
                else { return false }
            onError(AnError(errorDescription:
                LocalizedString.Location.timeout
            ), run: $0.process)
            return true
        }
        lock.unlock()
    }
    
    public static let serial = LocationManager()
    
    private lazy var manager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager?(manager, didChangeAuthorization: status)
        startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let name = placemarks?.first?.name {
                preferences.placemark = name
            }
        }
        callback(.current(location))
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        retryCount -= 1
        guard retryCount <= 0 else { return }
        manager.stopUpdatingLocation()
        onError(error)
    }
    
    private func startUpdatingLocation() {
        if Location.deniedAccess {
            onError(CLError.denied)
        } else {
            manager.startUpdatingLocation()
        }
    }
    
    private func onError(_ error: Error, run callback: ((Location) -> Void)! = nil) {
        let callback = callback ?? self.callback
        if let location = preferences.location {
            callback(.cached(location))
        } else {
            callback(.failed(error))
        }
    }
}

func alertLocationNotAvailable(dueTo error: Error? = nil) {
    runModal(ofNSAlert: { alert in
        alert.alertStyle = .warning
        alert.messageText = error == CLError.denied
            ? LocalizedString.Location.notAuthorized
            : LocalizedString.Location.notAvailable
        guard let error = error else { return }
        alert.informativeText = error.localizedDescription
    })
}
