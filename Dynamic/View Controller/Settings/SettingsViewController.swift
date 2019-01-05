//
//  SettingsViewController.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

extension NSStoryboard {
    static let main = NSStoryboard(name: "Main", bundle: nil)
}

class SettingsViewController: NSViewController {
    private static weak var window: NSWindow? = nil
    @objc public static func show() {
        if window == nil {
            ValueTransformer.setValueTransformer(
                UsesCustomRange(), forName: .usesCustomRangeTransformerName
            )
            let windowController = NSStoryboard.main
                .instantiateController(withIdentifier: "window")
                as! NSWindowController
            windowController.showWindow(nil)
            window = windowController.window
        }
        window?.windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    @IBAction func close(_ sender: Any) {
        SettingsViewController.window?.close()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // The following is required to attach touchbar to a view controller.
        // https://stackoverflow.com/questions/42342231/how-to-show-touch-bar-in-a-viewcontroller
        view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
        view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
        NSUserDefaultsController.shared.appliesImmediately = true
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        removeAllNotifications()
    }

    @IBAction func reSetup(_ sender: Any) {
        let name = Bundle.main.bundleIdentifier!
        preferences.removePersistentDomain(forName: name)
        Preferences.stopObserving()
        StatusBarItem.only.stopObserving()
        Scheduler.shared.cancel()
        ScreenBrightnessObserver.shared.stopObserving()
        close(self)
        Welcome.show()
    }
}

class UsesCustomRange: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return (value as? NSNumber)?.intValue == Zenith.custom.rawValue
    }
}

extension NSValueTransformerName {
    static let usesCustomRangeTransformerName
        = NSValueTransformerName(rawValue: "UsesCustomRange")
}
