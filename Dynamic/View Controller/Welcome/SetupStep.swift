//
//  SetupStep.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 12/11/18.
//  Copyright © 2018-2019 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

protocol SetupStep: AnyObject {
    func showNext()
}

var setupSteps = [NSViewController]()

func rewindSetupSteps() {
    while case let viewController? = setupSteps.popLast() {
        viewController.presentedViewControllers?.forEach {
            viewController.dismiss($0)
        }
    }
}

extension SetupStep where Self: NSViewController {
    func showNext() {
        setupSteps.append(self)
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "next", sender: nil)
        }
    }
}

protocol LastSetupStep: SetupStep { }

extension LastSetupStep {
    func showNext() {
        Welcome.close()
        preferences.hasLaunchedBefore = true
        Preferences.setupAsSuggested()
        Preferences.startObserving()
        AppleInterfaceStyle.coordinator.setup()
        SettingsViewController.show()
    }
}
