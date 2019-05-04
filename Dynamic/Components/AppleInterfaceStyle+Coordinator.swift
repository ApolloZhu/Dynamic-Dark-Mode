//
//  AppleInterfaceStyle+Coordinator.swift
//  Dynamic Dark Mode
//
//  Created by apollonian on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Foundation

extension AppleInterfaceStyle {
    public static let coordinator = AppleInterfaceStyleCoordinator()
}

/// This class coordinates between scheduler and screen brightness observer.
public class AppleInterfaceStyleCoordinator: NSObject {
    fileprivate override init() { super.init() }
    
    @objc public func toggleInterfaceStyle() {
        AppleInterfaceStyle.toggle()
    }
    
    public func setup() {
        tearDown()
        guard preferences.scheduled else {
            // No need for scheduler, only enable brightness observer
            return setupAdjustForBrightnessIfNecessary()
        }
        Scheduler.shared.getCurrentMode { [unowned self] result in
            switch result {
            case .success(let mode):
                mode.style.enable()
                if preferences.adjustForBrightness, // and don't observe brightness at night if disabled:
                    mode.style == .aqua || !preferences.disableAdjustForBrightnessWhenScheduledDarkModeOn {
                    ScreenBrightnessObserver.shared.startObserving(withInitialUpdate: false)
                } // no initial update because we are using the schedule
            case .failure(let error):
                // Nothing came back from schduler/location service,
                // let's at least try the brightness observer
                self.setupAdjustForBrightnessIfNecessary(or: {
                    // Nothing worked out, let the user know
                    Location.alertNotAvailable(dueTo: error)
                })
            }
            // We'll start the scheduler and brightness observer
            Scheduler.shared.schedule(enableCurrentStyle: false)
        }
    }
    
    private func setupAdjustForBrightnessIfNecessary(or doSomethingElse: () -> Void = { }) {
        if preferences.adjustForBrightness {
            ScreenBrightnessObserver.shared.startObserving()
        } else {
            doSomethingElse()
        }
    }
    
    public func tearDown() {
        Scheduler.shared.cancel()
        ScreenBrightnessObserver.shared.stopObserving()
    }
}
