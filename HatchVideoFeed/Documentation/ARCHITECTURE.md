# HatchVideoFeed Architecture Document

## Overview
HatchVideoFeed is designed as a **proof-of-concept iOS video feed application** to simulate a TikTok-like experience with infinite vertical scrolling, adaptive video preloading, and seamless playback.  
The architecture focuses on **performance**, **memory efficiency**, **smooth user experience**, and **scalable design**.

## Architecture Overview

### Hybrid UI Approach
- **SwiftUI**: Used for the app entry point and splash screen for quick UI prototyping.
- **UIKit**: Used for the video feed for precise control over scrolling performance and AVPlayer integration.
- **UIViewControllerRepresentable** bridges SwiftUI and UIKit.

**Flow**:
HatchVideoFeedApp (SwiftUI) → SplashView (SwiftUI) → VideoFeedContainer (SwiftUI) → VideoFeedViewController (UIKit) → VideoCell (UIKit)


## Core Components

### 1. `VideoFeedViewController`
- **Responsibilities**:
  - Fetches manifest JSON and loads video URLs.
  - Manages infinite scrolling with velocity-based snapping.
  - Controls video playback state (play/pause).
  - Handles prefetching logic.
- **Design Choice**:
  - Using `UICollectionView` with vertical scrolling for optimized performance and native paging support.
  - Snapping logic implemented in `scrollViewWillEndDragging` for natural UX.



### 2. `VideoCell`
- **Responsibilities**:
  - Contains a dedicated `AVPlayerLayer` for video playback.
  - Displays loading spinner, error messages, and retry functionality.
  - Hosts a custom `MessageInputBar` for user interaction.
- **Design Choice**:
  - Encapsulating video logic within cell for modularity and reusability.
  - Observes AVPlayerItem’s `status` for playback readiness and error handling.
  - Releasing players when cells are offscreen for memory efficiency.



### 3. `ManifestFetcher`
- **Responsibilities**:
  - Fetches manifest JSON from provided URL.
  - Decodes URLs into `VideoItem` objects.
- **Design Choice**:
  - Singleton pattern ensures single source of truth for manifest fetching.



### 4. `VideoPlayerManager`
- **Responsibilities**:
  - Manages AVPlayer instances for each URL.
  - Implements looping behavior.
  - Releases player resources when not needed.
- **Design Choice**:
  - Singleton pattern to ensure controlled and centralized AVPlayer management.
  - Prevents memory leaks and excessive resource usage.



### 5. `NetworkMonitor`
- **Responsibilities**:
  - Detects network conditions (fast/slow).
  - Notifies the app of network changes.
- **Design Choice**:
  - Singleton pattern with NWPathMonitor for lightweight background monitoring.
  - Drives adaptive prefetching.



### 6. `MessageInputBar`
- **Responsibilities**:
  - Custom input bar overlay for messages.
  - Handles keyboard events and send actions.
- **Design Choice**:
  - Reusable component to separate UI from playback logic.
  - Animations for smooth transitions when focusing/unfocusing text input.



## Key Design Decisions & Trade-offs

- **Hybrid SwiftUI + UIKit**:
  - SwiftUI for modern UI and rapid prototyping.
  - UIKit for fine-grained control of video playback and scrolling performance.
- **UICollectionView** over SwiftUI ScrollView:
  - Better performance for high-frame-rate video feeds.
  - More control over cell reuse, prefetching, and scrolling behavior.
- **Singleton Managers**:
  - Simplifies state management and resource sharing (manifest, players, network).
  - Trade-off: introduces tighter coupling, mitigated by small scope.



## Memory Management
- Players are reused and released when no longer visible.
- Cells are reused efficiently by UICollectionView.
- Prefetching limited to immediate neighbors to avoid unbounded memory growth.



## Smooth Transition Strategy
- **Snapping**: Scroll velocity is detected to snap to the next video naturally.
- **Prefetching**: Buffering is adaptive based on network speed (`NetworkMonitor`).
- **Playback Readiness**: Videos start only when ready, avoiding black frames.



## Prefetch Strategy
- Prefetch one video before and after current index.
- Prefetch buffer duration:
  - Fast network: larger buffer for smooth playback.
  - Slow network: smaller buffer to reduce memory usage and start faster.
- Implemented inside `VideoFeedViewController.prefetchVideos`.



## Error Handling
- Spinner UI while loading video.
- Retry button if playback fails (up to 3 attempts).
- Clear error label for better UX.



## Conclusion
This architecture balances **performance**, **memory efficiency**, and **smooth UX** while keeping the system extensible for future growth.  
The hybrid approach allows leveraging both SwiftUI and UIKit strengths for rapid development without compromising low-level control.
