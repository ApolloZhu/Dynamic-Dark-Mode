//
//  Location.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 11/17/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import CoreLocation

public enum Location {
    case current(CLLocation)
    case cached(CLLocation)
    case failed(Error)
    
    public typealias Processor = (Location) -> Void
}

extension Location {
    static var deniedAccess: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .notDetermined:
            return false
        case .denied, .restricted:
            return true
        }
    }
    
    static var allowsAccess: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        case .denied, .notDetermined, .restricted:
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
    private var isFetching = false
    private var retryCount = 5
    private var _callback: Location.Processor?
    private func callback(_ withLocation: Location) {
        lock.lock()
        _callback?(withLocation)
        _callback = nil
        isFetching = false
        lock.unlock()
    }
    
    public weak var delegate: CLLocationManagerDelegate?
    
    public func fetch(then processor: @escaping Location.Processor) {
        lock.lock()
        if isFetching { return lock.unlock() }
        isFetching = true
        retryCount = 5
        _callback = processor
        lock.unlock()
        if Location.deniedAccess {
            callback(.failed(CLError.denied))
        } else {
            manager.startUpdatingLocation()
        }
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
        if Location.deniedAccess {
            manager.stopUpdatingLocation()
            callback(.failed(CLError.denied))
        } else {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        callback(.current(location))
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        retryCount -= 1
        guard retryCount == 0 else { return }
        manager.stopUpdatingLocation()
        if let location = preferences.location {
            callback(.cached(location))
        } else {
            callback(.failed(error))
        }
    }
}

func alertLocationNotAvailable(dueTo error: Error? = nil) {
    runModal(ofNSAlert: { alert in
        alert.messageText = error == CLError.denied
            ? LocalizedString.Location.notAuthorized
            : LocalizedString.Location.notAvailable
        if let errorDescription = error?.localizedDescription {
            alert.informativeText = errorDescription
        }
        alert.alertStyle = .warning
    })
}
