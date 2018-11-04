# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Chinese translation of toggle dark mode

### Fixed
- No scheduled change during sleep

## [1.0.6] - 2018-10-22
### Added
- French translation
- Indonesian translation
- Russian translation
- German translation

### Fixed
- Some parts of the interface elements been cut off

### Removed
- Hope to be included in the Mac App Store

## [1.0.5] - 2018-09-30
### Fixed
- False alarm about `-1751` AppleScript error
- Wrongly turning on dark mode when custom schedule spans within a single day

## [1.0.4] - 2018-09-29
### Added
- Simplfied Chinese Translation

## [1.0.3] - 2018-09-29
### Added
- installer pkg for download
- Request for location access during setup process
- Button in app's preferences pane to rerun setup process

### Fixed
- Crash on launch (if the app is installed in the `/Applications` folder)

## [1.0.2] - 2018-09-28
### Changed
- Start using non-sandbox-escaping method to control System Events

### Removed
- Request to access `~/Library/Application Scripts/${bundleIdentifier}`

## [1.0.1] - 2018-09-26
### Added
- Ability to switch dark mode when global shortcut key combination is performed
- Ability to toggle dark mode when screen brightness is below/above a set threshold
- Ability to turn on/off dark mode based on a scheduled time
- Ability to automatically set scheduled time as sunset/sunrise based on location
