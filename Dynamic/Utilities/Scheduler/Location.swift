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
    
    private var retryCount = 5
    private let timeout = Interval(seconds: 2)
    private var _callbacks: [(id: UUID, process: Location.Processor, onTimeout: Task)] = [] {
        didSet {
            if _callbacks.isEmpty {
                manager.stopUpdatingLocation()
            }
        }
    }
    private func callback(_ location: Location) {
        lock.lock()
        defer { lock.unlock() }
        guard !_callbacks.isEmpty else { return }
        let task = _callbacks.removeFirst()
        task.onTimeout.cancel()
        task.process(location)
        retryCount = 5
    }
    
    public weak var delegate: CLLocationManagerDelegate?
    
    public func fetch(then processor: @escaping Location.Processor) {
        lock.lock()
        let id = UUID()
        _callbacks.append((id, processor, Plan.after(timeout).do { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            defer { self.lock.unlock() }
            self._callbacks.removeAll { $0.id == id }
            self.onError(AnError(errorDescription:
                LocalizedString.Location.timeout
            ), run: processor)
        }))
        lock.unlock()
        startUpdatingLocation()
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
