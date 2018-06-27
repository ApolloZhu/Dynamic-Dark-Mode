//
//  SettingsViewController+TouchBarSupport.swift
//  Dynamic
//
//  Created by Captain雪ノ下八幡 on 2018/6/27.
//  Copyright © 2018 Apollonian. All rights reserved.
//
import AppKit

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
            popoverItem.collapsedRepresentationLabel = String.Localized.SettingsViewController.autoAdjustThreshold
            popoverItem.view?.bind(.enabled, to: sharedUserDefaultsController, withKeyPath: "values.adjustForBrightness", options: nil)
            return popoverItem
        case SubTouchBarItemIdentifiers.thresholdSliderItem.rawValue:
            let sliderItem = NSSliderTouchBarItem(identifier: identifier)
            sliderItem.label = String.Localized.SettingsViewController.autoAdjustThreshold
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
            popoverItem.collapsedRepresentationLabel = String.Localized.SettingsViewController.scheduleMode
            popoverItem.popoverTouchBar = scrubberTouchBar
            popoverItem.view?.bind(.enabled, to: sharedUserDefaultsController, withKeyPath: "values.scheduled", options: nil)
            return popoverItem
        case SubTouchBarItemIdentifiers.scheduleTypeScrubberItem.rawValue:
            let scrubber = NSScrubber()
            scrubber.dataSource = self
            scrubber.delegate = self
            scrubber.floatsSelectionViews = true
            scrubber.isContinuous = true
            scrubber.mode = .fixed
            scrubber.floatsSelectionViews = true
            scrubber.selectionOverlayStyle = .outlineOverlay
            scrubber.scrubberLayout = NSScrubberProportionalLayout(numberOfVisibleItems: 5)
            scrubber.backgroundColor = .scrubberTexturedBackground
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
