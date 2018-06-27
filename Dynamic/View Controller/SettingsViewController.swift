//
//  SettingsViewController.swift
//  Dynamic
//
//  Created by Apollo Zhu on 6/9/18.
//  Copyright © 2018 Apollonian. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    private static weak var window: NSWindow? = nil
    public static func show() {
        if window == nil {
            ValueTransformer.setValueTransformer(
                UsesCustomRange(), forName: .usesCustomRangeTransformerName
            )
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyboard
                .instantiateController(withIdentifier: "window")
                as! NSWindowController
            windowController.showWindow(nil)
            window = windowController.window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    @IBOutlet var sharedUserDefaultsController: NSUserDefaultsController!

    override func viewDidAppear() {
        super.viewDidAppear()
        // Make the touch bar visible, check out the link below to view the magic.
        // https://stackoverflow.com/questions/42342231/how-to-show-touch-bar-in-a-viewcontroller
        view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
        view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
    }

    deinit {
        NSUserDefaultsController.shared.save(nil)
        Preferences.reload()
    }
}

extension SettingsViewController: NSScrubberDataSource, NSScrubberDelegate {

    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return 5
    }

    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let view = NSScrubberTextItemView()
        switch index {
        case 0:
            view.title = String.Localized.SettingsViewController.official
        case 1:
            view.title = String.Localized.SettingsViewController.civil
        case 2:
            view.title = String.Localized.SettingsViewController.nautical
        case 3:
            view.title = String.Localized.SettingsViewController.astronimical
        case 4:
            view.title = String.Localized.SettingsViewController.customRange
        default:
            fatalError("Unexpected index number")
        }
        return view
    }

    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        Preferences.scheduleType = Scheduler.Zenith(rawValue: selectedIndex)!
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
        return (value as? NSNumber)?.intValue
            == Scheduler.Zenith.custom.rawValue
    }
}

extension NSValueTransformerName {
    static let usesCustomRangeTransformerName
        = NSValueTransformerName(rawValue: "UsesCustomRange")
}

extension Preferences {
    public static func reload() {
        Preferences.adjustForBrightness = Preferences.adjustForBrightness
        Preferences.brightnessThreshold = Preferences.brightnessThreshold
        Preferences.scheduled = Preferences.scheduled
        Preferences.scheduleType = Preferences.scheduleType
        Preferences.opensAtLogin = Preferences.opensAtLogin
    }
    
    public static func setup() {
        Preferences.adjustForBrightness = true
        Preferences.brightnessThreshold = 0.5
        #warning("TODO: Implement SunsetSunriseProvider")
        Preferences.scheduled = true
        Preferences.scheduleType = .official
        Preferences.opensAtLogin = true
        Preferences.hasLaunchedBefore = true
    }
}
