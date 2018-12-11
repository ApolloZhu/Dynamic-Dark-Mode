//
//  StatusBarItem.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 12/11/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import AppKit

public final class StatusBarItem {
    public static let only = StatusBarItem()
    private init() { }

    enum Style: Int {
        case menu
        case rightClick
        case hidden
    }
    
    private var statusBarItem: NSStatusItem?
    
    private func createStatusBarItemIfNecessary() {
        guard statusBarItem == nil else { return }
        statusBarItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )
        statusBarItem?.button?.image = #imageLiteral(resourceName: "status_bar_icon")
        statusBarItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusBarItem?.button?.action = #selector(handleEvent)
        statusBarItem?.button?.target = self
    }
    
    @objc private func handleEvent() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            SettingsViewController.show()
        } else {
            AppleInterfaceStyle.toggle()
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let toggleItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.toggle",
                comment: "Action item to toggle in from menu bar"),
            action: #selector(handleEvent),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        let preferencesItem = NSMenuItem(
            title: NSLocalizedString(
                "Menu.preferences",
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
                comment: "Use system translation for quit"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "Q"
        )
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        return menu
    }
    
    private var settingsStyleObservation: NSKeyValueObservation?
    
    public func startObserving() {
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
            }
        }
    }
    
    public func stopObserving() {
        settingsStyleObservation?.invalidate()
    }
}
