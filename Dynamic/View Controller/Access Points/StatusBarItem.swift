//
//  StatusBarItem.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 12/11/18.
//  Copyright © 2018-2022 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

public final class StatusBarItem {
    public static let only = StatusBarItem()
    private init() { }
    
    enum Style: Int {
        case menu
        case rightClick
        case hidden
    }
    
    private var statusBarItem: NSStatusItem?
    
    private var statusBarItemImage: NSImage {
        AppleInterfaceStyle.isDark ? #imageLiteral(resourceName: "dark") : #imageLiteral(resourceName: "light")
    }
    
    private func createStatusBarItemIfNecessary() {
        guard statusBarItem == nil else { return }
        statusBarItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )
        statusBarItem?.button?.image = statusBarItemImage
        statusBarItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusBarItem?.button?.action = #selector(handleEvent)
        statusBarItem?.button?.target = self
    }
    
    @objc private func handleEvent() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            SettingsViewController.show()
        } else {
            AppleInterfaceStyle.Coordinator.toggleOrShowInterface()
        }
    }
    
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let toggleItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.toggle",
                value: "Toggle Dark Mode",
                comment: "Action item to toggle in from menu bar"),
            action: #selector(handleEvent),
            keyEquivalent: ""
        )
        toggleItem.target = self
        if #available(macOS 10.15, *) {
            toggleItem.bindEnabledToNotAppleInterfaceStyleSwitchesAutomatically()
        }
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        let preferencesItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.preferences",
                value: "Preferences…",
                comment: "Drop down menu item to show preferences"),
            action: #selector(SettingsViewController.show),
            keyEquivalent: ","
        )
        preferencesItem.keyEquivalentModifierMask = .command
        preferencesItem.target = SettingsViewController.self
        menu.addItem(preferencesItem)
        let quitItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.quit",
                value: "Quit",
                comment: "Use system translation for quit"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "Q"
        )
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        return menu
    }
    
    private var appearanceObservation: NSKeyValueObservation?
    private var settingsStyleObservation: NSKeyValueObservation?
    
    public func startObserving() {
        appearanceObservation = NSApp.observe(\.effectiveAppearance) {
            [weak self] _, _ in
            guard let self = self else { return }
            self.statusBarItem?.button?.image = self.statusBarItemImage
        }
        settingsStyleObservation = preferences.observe(
            \.rawSettingsStyle, options: [.initial, .new]
        ) { [weak self] _, change in
            guard let self = self else { return }
            switch preferences.settingsStyle {
            case .menu:
                self.createStatusBarItemIfNecessary()
                self.statusBarItem?.menu = self.buildMenu()
            case .rightClick:
                self.createStatusBarItemIfNecessary()
                self.statusBarItem?.menu = nil
            case .hidden:
                guard let statusBarItem = self.statusBarItem else { return }
                NSStatusBar.system.removeStatusItem(statusBarItem)
                self.statusBarItem = nil
            }
        }
    }
    
    public func stopObserving() {
        appearanceObservation?.invalidate()
        settingsStyleObservation?.invalidate()
    }
}
