//
//  SetupStep.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 12/11/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
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
    
    func needsPermission(_ message: String,
                         openPreferences: @escaping () -> Void,
                         skip: @escaping () -> Void) {
        showAlert(withConfiguration: { alert in
            alert.messageText = message
            alert.addButton(withTitle: NSLocalizedString(
                "SystemPreferences.open",
                value: "Open System Preferences",
                comment: ""
            ))
            alert.addButton(withTitle: NSLocalizedString(
                "SystemPreferences.skip",
                value: "Skip",
                comment: "Translate the same as in all other setup process"
            ))
            alert.alertStyle = .warning
        }, then: { response in
            switch response {
            case .alertFirstButtonReturn:
                openPreferences()
            case .alertSecondButtonReturn:
                skip()
            default:
                fatalError("Unhandled authorization response")
            }
        })
    }
}

protocol LastSetupStep: SetupStep { }

extension LastSetupStep {
    func showNext() {
        Welcome.skip()
    }
}
