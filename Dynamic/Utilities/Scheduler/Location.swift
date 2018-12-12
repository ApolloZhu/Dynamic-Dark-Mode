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

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    private var isFetching = false
    private var retryCount = 5
    private var _callback: Location.Processor?
    private var callback: Location.Processor? {
        get {
            defer {
                _callback = nil
                isFetching = false
            }
            return _callback
        }
        set {
            _callback = newValue
        }
    }
    
    public func fetch(then processor: @escaping Location.Processor) {
        if isFetching { return }
        isFetching = true
        retryCount = 5
        callback = processor
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .notDetermined:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            break
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
            break
        case .denied, .restricted:
            runModal(ofNSAlert: { alert in
                alert.messageText = LocalizedString.Location.notAuthorized
            })
            manager.stopUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        preferences.location = location
        callback?(.current(location))
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        retryCount -= 1
        guard retryCount == 0 else { return }
        manager.stopUpdatingLocation()
        if let location = preferences.location {
            callback?(.cached(location))
        } else {
            callback?(.failed(error))
        }
    }
}
