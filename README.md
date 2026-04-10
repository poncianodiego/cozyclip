# CozyClip

A simple, lightweight clipboard manager for macOS. Lives in your menu bar, stores everything you copy, and lets you paste it again.

## Features

- Menu bar app — no dock icon, stays out of your way
- Automatically captures everything you copy or cut
- Click any clip to copy it back to your clipboard
- Search across all saved clips
- Delete individual clips or clear all with confirmation
- Persists clipboard history across app restarts (up to 50 items)
- Right-click the menu bar icon to quit

## Supported Devices

- **Platform:** macOS only
- **Minimum version:** macOS 13.0 (Ventura)
- **Architecture:** Apple Silicon (arm64) and Intel (x86_64)

## Build

```bash
./build-dmg.sh
```

This builds the app and creates `CozyClip.dmg`. Alternatively, build directly with Xcode:

```bash
open CozyClip.xcodeproj
```

## Install

Build the app, then either:
- Open `CozyClip.dmg` and drag to Applications, or
- Run directly: `open build/Build/Products/Release/CozyClip.app`

## License

[MIT](LICENSE)
