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

// MARK: Touch Bar Support Implementation

extension SettingsViewController: NSTouchBarDelegate {

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = NSTouchBarItem.Identifier.Settings.allMainItems
        return touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier.rawValue {
        case MainTouchBarItemIdentifiers.thresholdPopoverItem.rawValue:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            let sliderTouchBar = NSTouchBar()
            sliderTouchBar.defaultItemIdentifiers = [NSTouchBarItem.Identifier(SubTouchBarItemIdentifiers.thresholdSliderItem.rawValue)]
            sliderTouchBar.delegate = self
            popoverItem.popoverTouchBar = sliderTouchBar
            popoverItem.pressAndHoldTouchBar = sliderTouchBar
            popoverItem.collapsedRepresentationLabel = NSLocalizedString("io.github.apollozhu.Dynamic.AutoAdjustThreshold", comment: "Auto Adjust Threshold")
            popoverItem.view?.bind(.enabled, to: sharedUserDefaultsController, withKeyPath: "values.adjustForBrightness", options: nil)
            return popoverItem
        case SubTouchBarItemIdentifiers.thresholdSliderItem.rawValue:
            let sliderItem = NSSliderTouchBarItem(identifier: identifier)
            sliderItem.label = NSLocalizedString("io.github.apollozhu.Dynamic.AutoAdjustThreshold", comment: "Auto Adjust Threshold")
            sliderItem.slider.minValue = 0
            sliderItem.slider.maxValue = 100
            sliderItem.slider.bind(.value, to: sharedUserDefaultsController, withKeyPath: "values.brightnessThreshold", options: nil)
            sliderItem.slider.bind(.enabled, to: sharedUserDefaultsController, withKeyPath: "values.adjustForBrightness", options: nil)
            #warning("TODO: Consider to add NSSliderAccessories here? (images required)")
            return sliderItem
        case MainTouchBarItemIdentifiers.scheduleTypePopoverItem.rawValue:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            let scrubberTouchBar = NSTouchBar()
            scrubberTouchBar.defaultItemIdentifiers = [NSTouchBarItem.Identifier(rawValue: SubTouchBarItemIdentifiers.scheduleTypeScrubberItem.rawValue)]
            scrubberTouchBar.delegate = self
            popoverItem.collapsedRepresentationLabel = NSLocalizedString("io.github.apollozhu.Dynamic.ScheduleMode", comment: "Schedule Mode")
            popoverItem.popoverTouchBar = scrubberTouchBar
            popoverItem.view?.bind(.enabled, to: sharedUserDefaultsController, withKeyPath: "values.scheduled", options: nil)
            return popoverItem
        case SubTouchBarItemIdentifiers.scheduleTypeScrubberItem.rawValue:
            let scrubber = NSScrubber()
            scrubber.dataSource = self
            scrubber.floatsSelectionViews = true
            scrubber.isContinuous = true
            scrubber.mode = .fixed
            scrubber.floatsSelectionViews = true
            scrubber.selectionOverlayStyle = .outlineOverlay
            scrubber.scrubberLayout = NSScrubberProportionalLayout(numberOfVisibleItems: 5)
            scrubber.backgroundColor = .scrubberTexturedBackground
            #warning("BUG: Selected index not binded correctly.")
            scrubber.bind(.selectedIndex, to: sharedUserDefaultsController, withKeyPath: "values.scheduleType", options: nil)
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)
            scrubberItem.view = scrubber
            return scrubberItem
        default:
            fatalError("Unexpected identifier")
        }
    }

    enum MainTouchBarItemIdentifiers: String, CaseIterable {
        case thresholdPopoverItem
        case scheduleTypePopoverItem
    }

    enum SubTouchBarItemIdentifiers: String, CaseIterable {
        case thresholdSliderItem
        case scheduleTypeScrubberItem
    }

}

extension NSTouchBarItem.Identifier {

    struct Settings {
        static let allMainItems: [NSTouchBarItem.Identifier] = SettingsViewController.MainTouchBarItemIdentifiers.allCases.map { return NSTouchBarItem.Identifier(rawValue: $0.rawValue) }
        private init() {}
    }

}

extension SettingsViewController: NSScrubberDataSource {

    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return 5
    }

    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let view = NSScrubberTextItemView()
        switch index {
        case 0:
            view.title = NSLocalizedString("io.github.apollozhu.Dynamic.Official", comment: "Official")
        case 1:
            view.title = NSLocalizedString("io.github.apollozhu.Dynamic.Civil", comment: "Civil")
        case 2:
            view.title = NSLocalizedString("io.github.apollozhu.Dynamic.Nautical", comment: "Nautical")
        case 3:
            view.title = NSLocalizedString("io.github.apollozhu.Dynamic.Astronimical", comment: "Astronimical")
        case 4:
            view.title = NSLocalizedString("io.github.apollozhu.Dynamic.CustomRange", comment: "Custom Range")
        default:
            fatalError("Unexpected index number")
        }
        return view
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
