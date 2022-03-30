//
//  AllowLocationViewController.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 9/28/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import Cocoa
import CoreLocation

class AllowLocationViewController: NSViewController, LastSetupStep {
    
    @IBOutlet weak var showPreferences: NSButton!
    
    var whenNotAuthorized: Bool {
        if Location.allowsAccess {
            showNextOnce()
            return false
        } else {
            return true
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        guard whenNotAuthorized else { return }
        showPreferences.isHidden = false
        LocationManager.serial.delegate = self
        LocationManager.serial.fetch { [weak self] in
            switch $0 {
            case .failed(let error):
                self?.onError(error)
            case .cached:
                self?.onError()
            case .current:
                self?.showNextOnce()
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func skip(_ sender: Any) {
        showNextOnce()
    }
    
    @IBAction func openPreferences(_ sender: NSButton) {
        guard whenNotAuthorized else { return }
        redirectToSystemPreferences()
    }
    
    private var firstTime = true
    
    func showNextOnce() {
        if firstTime {
            firstTime = false
            showNext()
        }
    }
}

private func redirectToSystemPreferences() {
    openURL("x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")
}

// MARK: - Delegate Implementation

extension AllowLocationViewController: CLLocationManagerDelegate {
    private func onError(_ error: Error? = nil) {
        needsPermission(error == CLError.denied
            ? LocalizedString.Location.notAuthorized
            : LocalizedString.Location.notAvailable,
                        openPreferences: redirectToSystemPreferences,
                        skip: showNextOnce)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        _ = whenNotAuthorized
    }
}
