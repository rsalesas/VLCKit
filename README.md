# VLCKit-SPM

Swift Package Manager support for VLCKit with full API access.

## Version
This package tracks official MobileVLCKit 3.6.0 from VideoLAN (`pod 'MobileVLCKit' 3.6.0`).

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rsaleass/VLCKit-SPM", from: "3.6.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/rsaleass/VLCKit-SPM`
3. Select version `3.6.0` or later

## Usage

```swift
import VLCKitSPM

// Create a media player
let mediaPlayer = VLCMediaPlayer()

// Load media from URL
let media = VLCMedia(url: URL(string: "https://example.com/video.mp4")!)
mediaPlayer.media = media

// Play
mediaPlayer.play()
```


---

This package fills the gap until VideoLAN releases official SPM support in VLCKit v4.0.
