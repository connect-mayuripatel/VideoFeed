# HatchVideoFeed

## Overview
HatchVideoFeed is a proof-of-concept iOS application that implements an infinite-scrolling vertical video feed similar to TikTok or Instagram Reels.  
The app is designed to deliver a smooth, performant, and engaging user experience by streaming videos via HLS manifests.

This challenge demonstrates architectural thinking, efficient memory and network usage, and smooth playback.

## Features
- **Infinite Vertical Scrolling** — seamless looping between videos.
- **Automatic Playback** — videos auto-play when visible.
- **Looping** — videos loop automatically at end.
- **Smooth Transitions** — velocity-based snapping to make scrolling fluid.
- **Playback Readiness** — prevents moving to next video until ready to avoid blank screens.
- **Adaptive Prefetching** — adjusts preloading buffer based on network speed.
- **Error Handling** — retry option with visual feedback.
- **Custom Input Bar** — for messaging overlay.

## Architecture
HatchVideoFeed uses a hybrid SwiftUI + UIKit approach:

- **UI Layer**: `VideoFeedContainer` (SwiftUI) hosts `VideoFeedViewController`.
- **Controller Layer**: Handles video list, infinite scrolling, and snapping logic.
- **Cell Layer**: `VideoCell` handles AVPlayer playback, input bar, and error UI.
- **Service Layer**:
  - `ManifestFetcher` — fetches video manifest JSON.
  - `VideoPlayerManager` — manages AVPlayer instances and looping.
  - `NetworkMonitor` — detects network speed to adapt prefetching.

For more details, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Installation
1. Clone the repository:
```bash
git clone https://github.com/connect-mayuripatel/HatchVideoFeed.git 
```
2. Open the project in Xcode (HatchVideoFeed.xcodeproj).
3. Select a simulator or connect an iOS device.
4. Build and run.

## Usage
- Launch the app.
- The splash screen appears with logo animation.
- The video feed starts automatically.
- Swipe up/down to navigate through videos.
- Tap the message bar to send a message (logs to console).

## Dependencies
- Swift 5+
- iOS 16+
- AVFoundation
- SwiftUI + UIKit

## Build Instructions
- Open HatchVideoFeed.xcodeproj in Xcode 16+.
- Select target device or simulator.
- Press Cmd + R to run.
- Wait for the splash animation, then explore the video feed.
