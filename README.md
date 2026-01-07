# AppNetworkMonitor Client (macOS)

[![Platform](https://img.shields.io/badge/Platform-macOS%2012.0%2B-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

**AppNetworkMonitor Client** is the desktop companion application for the [AppNetworkMonitor iOS Library](https://github.com/christianalexandre/app-network-monitor).

It acts as a local server, listening for incoming connections from your iOS apps via Bonjour/TCP. It allows you to inspect network traffic, logs, and metrics in real-time on a large screen, without cluttering the device UI.

## Features

- **Zero-Config Discovery:** Uses Bonjour (`_appmonitor._tcp`) to automatically find and connect to iOS devices running the `AppNetworkMonitor` agent.
- **Real-Time Streaming:** Watch requests, responses, and errors appear instantly as they happen on the device.
- **Deep Inspection:** View JSON bodies, HTTP headers, and status codes with syntax highlighting.
- **Multi-Session:** Handles connections from multiple devices/simulators simultaneously.
- **Search & Filter:** Quickly find specific endpoints or failed requests.

## Installation & Running

Since this application is distributed outside the Mac App Store (and is unsigned), macOS Gatekeeper might block its execution.

### Option A: Building from Source (Recommended)
1. Clone this repository.
2. Open `AppNetworkMonitorClient.xcodeproj` in Xcode.
3. Select your Mac as the destination.
4. Press **Cmd + R** to build and run.

### Option B: Running the Pre-compiled App
If you received the `.app` file or downloaded a release version:

1. Unzip the file.
2. Drag `AppNetworkMonitor.app` to your **Applications** folder (optional).
3. **First-time run fix:** If you see a message saying *"App is damaged"* or *"Can't be opened"*, run the following command in Terminal to bypass the quarantine:
    ```bash
    # Replace path/to/app with the actual location
    sudo xattr -cr /Applications/AppNetworkMonitor.app
    ```
4. Double-click to open.

## How to Use

1. **Launch the Mac App:** It will immediately start listening for connections on the local network.
2. **Launch your iOS App:** Ensure your iOS app (instrumented with the AppNetworkMonitor library) is on the same Wi-Fi network.
3. **Automatic Connection:** The iOS app will discover the Mac Client via Bonjour and establish a connection. You should see logs appearing instantly.

## License

This project is licensed under the MIT License - see the LICENSE file for details.