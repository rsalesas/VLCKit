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

## Features

✅ **Complete VLCKit API access** (including VLCMediaDiscoverer)  
✅ **iOS, tvOS support** (iOS 11+, tvOS 11+)  
✅ **Pre-built XCFramework** (~200MB, managed with Git LFS)  
✅ **Swift Package Manager native**  
✅ **All advanced features included**  

## What's Included

This package includes **ALL** VLCKit APIs, unlike other SPM wrappers:

### Core Components
- `VLCMediaPlayer` - Main media playback engine
- `VLCMedia` - Media resource handling with metadata parsing
- `VLCMediaList` - Playlist and media list management
- `VLCMediaListPlayer` - Playlist player functionality

### Network & Discovery
- `VLCMediaDiscoverer` - Network browsing (UPnP, Bonjour, etc.)
- `VLCRendererDiscoverer` - Chromecast and AirPlay discovery
- Network streaming protocols (HTTP, RTSP, etc.)

### Advanced Features
- Audio/video filters and effects
- Subtitle handling and text rendering  
- Chapter and title navigation
- Audio/video track selection
- Equalizer and audio processing
- Screenshot and thumbnail generation
- Media parsing with subitems (for playlists, directories)

### Missing from Other Packages
Many existing SPM wrappers for VLCKit omit crucial APIs like:
- ❌ VLCMediaDiscoverer (network browsing)
- ❌ Advanced media parsing
- ❌ Renderer discovery
- ❌ Complete filter system

This package provides **100% API coverage**.

## Building from Source

### Prerequisites
- Xcode 13+ 
- macOS 12+ (for building)
- Git LFS installed (`brew install git-lfs`)

### Quick Build (Recommended)

```bash
# Clone this repository
git clone https://github.com/rsaleass/VLCKit-SPM.git
cd VLCKit-SPM

# Download prebuilt MobileVLCKit 3.6.0 from CocoaPods (fast)
./build-scripts/download-mobilevlckit.sh
```

### Build from Source (Advanced)

```bash
# Build from VideoLAN source (takes 30-60 minutes)
./build-scripts/build-xcframework.sh
```

The quick script will:
1. Download prebuilt MobileVLCKit 3.6.0 via CocoaPods
2. Create XCFramework for SPM distribution
3. Verify framework integrity

The source build script will:
1. Clone official VLCKit 3.6.0 source from VideoLAN
2. Build for iOS/tvOS (MobileVLCKit)
3. Build for macOS (VLCKit)  
4. Create universal XCFramework
5. Show build information and size

## Git LFS Setup

This package uses Git LFS to handle the large XCFramework (~200MB):

```bash
# Initialize Git LFS (one time setup)
git lfs install

# Track framework files  
git lfs track "*.xcframework"
git lfs track "*.framework"

# Verify LFS is working
git lfs ls-files
```

## Version Strategy

This package follows VLCKit's official versioning:
- **3.6.0** - Matches VLCKit 3.6.0 exactly
- **3.6.0-spm.1** - SPM-specific patches if needed
- **3.6.x** - Future 3.6.x releases from VideoLAN

## Platform Support

| Platform | Minimum Version | Architecture |
|----------|----------------|--------------|
| iOS      | 11.0           | arm64, x86_64, i386 |
| tvOS     | 11.0           | arm64        |

## Examples

### Media Discovery (Network Browsing)

```swift
import VLCKitSPM

// Discover UPnP/DLNA servers
let discoverer = VLCMediaDiscoverer(name: "upnp")
discoverer?.delegate = self
discoverer?.startDiscovering()

// VLCMediaDiscovererDelegate
func mediaDiscoverer(_ aDiscoverer: VLCMediaDiscoverer, 
                    didDiscoverMedia media: VLCMedia) {
    print("Found media: \\(media.metaData.title)")
    
    // Parse media for subitems (folders, playlists)
    media.parseWithOptions(.parseNetwork)
}
```

### Advanced Media Parsing

```swift
// Parse a playlist or folder
let media = VLCMedia(url: playlistURL)
media.delegate = self
media.parseWithOptions([.parseNetwork, .parseLocal])

// VLCMediaDelegate
func mediaDidFinishParsing(_ media: VLCMedia) {
    // Access subitems (files in folder, playlist entries)
    let subitems = media.subitems
    print("Found \\(subitems.count) items")
}
```

### Renderer Discovery (Chromecast/AirPlay)

```swift
// Discover Chromecast devices
let rendererDiscoverer = VLCRendererDiscoverer(name: "chromecast")
rendererDiscoverer?.delegate = self
rendererDiscoverer?.start()
```

## Comparison with Other Packages

| Package | API Coverage | Network Discovery | Active Maintenance | VLCKit Version |
|---------|-------------|-------------------|-------------------|----------------|
| **rsaleass/VLCKit-SPM** | ✅ 100% | ✅ Full | ✅ Yes | 3.6.0 |
| tylerjonesio/vlckit-spm | ❌ ~60% | ❌ Missing | ❌ Stale | 3.3.0 |
| Others | ❌ Limited | ❌ Missing | ❌ Various | Mixed |

## License

LGPL v2.1 - Same as VLCKit

This package redistributes VLCKit under the terms of the GNU Lesser General Public License as published by the Free Software Foundation.

## Credits

- **VLCKit**: Official media framework by VideoLAN
- **VLC**: The renowned open-source media player
- **Package**: Community SPM wrapper by @rsaleass

Built from official VLCKit 3.6.0: https://code.videolan.org/videolan/VLCKit

## Support

- **Issues**: [GitHub Issues](https://github.com/rsaleass/VLCKit-SPM/issues)
- **VLCKit Documentation**: [VideoLAN Wiki](https://wiki.videolan.org/VLCKit/)
- **VLC Forum**: [VideoLAN Forum](https://forum.videolan.org/)

---

This package fills the gap until VideoLAN releases official SPM support in VLCKit v4.0.