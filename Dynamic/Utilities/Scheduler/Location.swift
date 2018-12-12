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

public final class LocationManager: NSObject, CLLocationManagerDelegate {
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
    
    public func fetch(then processor: @escaping Location.Processor) {
        lock.lock()
        if isFetching { return lock.unlock() }
        isFetching = true
        retryCount = 5
        _callback = processor
        lock.unlock()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .notDetermined:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            callback(.failed(CLError.denied))
        }
    }
    
    public static let serial = LocationManager()
    
    private lazy var manager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .notDetermined:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
            callback(.failed(CLError.denied))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        callback(.current(location))
    }
    
    public func locationManager(_ manager: CLLocationManager,
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
