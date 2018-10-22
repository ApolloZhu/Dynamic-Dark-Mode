//
//  TouchBarForSettingsVC.swift
//  Dynamic
//
//  Created by Captain雪ノ下八幡 on 2018/6/27.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//
import AppKit

extension SettingsViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.thresholdPopoverItem, .scheduleTypePopoverItem]
        return touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let defaultsController = NSUserDefaultsController.shared
        switch identifier {
        case .thresholdPopoverItem:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            let sliderTouchBar = NSTouchBar()
            sliderTouchBar.defaultItemIdentifiers = [.thresholdSubSliderItem]
            sliderTouchBar.delegate = self
            popoverItem.popoverTouchBar = sliderTouchBar
            popoverItem.pressAndHoldTouchBar = sliderTouchBar
            popoverItem.collapsedRepresentationLabel = LocalizedString.SettingsViewController.autoAdjustThreshold
            popoverItem.view?.bind(.enabled, to: defaultsController, withKeyPath: "values.adjustForBrightness", options: nil)
            return popoverItem
        case .thresholdSubSliderItem:
            let sliderItem = NSSliderTouchBarItem(identifier: identifier)
            sliderItem.label = LocalizedString.SettingsViewController.autoAdjustThreshold
            sliderItem.slider.minValue = 0
            sliderItem.slider.maxValue = 100
            sliderItem.slider.bind(.value, to: defaultsController, withKeyPath: "values.brightnessThreshold", options: nil)
            sliderItem.slider.bind(.enabled, to: defaultsController, withKeyPath: "values.adjustForBrightness", options: nil)
            return sliderItem
        case .scheduleTypePopoverItem:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            let scrubberTouchBar = NSTouchBar()
            scrubberTouchBar.defaultItemIdentifiers = [.scheduleTypeSubScrubberItem]
            scrubberTouchBar.delegate = self
            popoverItem.collapsedRepresentationLabel = LocalizedString.SettingsViewController.scheduleMode
            popoverItem.popoverTouchBar = scrubberTouchBar
            popoverItem.view?.bind(.enabled, to: defaultsController, withKeyPath: "values.scheduled", options: nil)
            return popoverItem
        case .scheduleTypeSubScrubberItem:
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
            scrubber.bind(.selectedIndex, to: defaultsController, withKeyPath: "values.scheduleType", options: nil)
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)
            scrubberItem.view = scrubber
            return scrubberItem
        default:
            fatalError("Unexpected identifier")
        }
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
            view.title = LocalizedString.SunsetSunrise.official
        case 1:
            view.title = LocalizedString.SunsetSunrise.civil
        case 2:
            view.title = LocalizedString.SunsetSunrise.nautical
        case 3:
            view.title = LocalizedString.SunsetSunrise.astronomical
        case 4:
            view.title = LocalizedString.SunsetSunrise.customRange
        default:
            fatalError("Unexpected index number")
        }
        return view
    }

    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        preferences.scheduleType = selectedIndex
    }
}

extension NSTouchBarItem.Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

extension NSTouchBarItem.Identifier {
    static let thresholdPopoverItem = "thresholdPopoverItem" as NSTouchBarItem.Identifier
    static let scheduleTypePopoverItem = "scheduleTypePopoverItem" as NSTouchBarItem.Identifier
    static let thresholdSubSliderItem = "thresholdSubSliderItem" as NSTouchBarItem.Identifier
    static let scheduleTypeSubScrubberItem = "scheduleTypeSubSliderItem" as NSTouchBarItem.Identifier
}
