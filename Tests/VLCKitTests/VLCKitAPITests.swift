import XCTest
import VLCKit

final class VLCKitAPITests: XCTestCase {
    
    func testMediaPlayerAvailable() {
        let mediaPlayer = VLCMediaPlayer()
        XCTAssertNotNil(mediaPlayer, "VLCMediaPlayer should be available")
    }
    
    func testMediaDiscovererAvailable() {
        // This API is missing in tylerjonesio/vlckit-spm and other packages
        let discoverer = VLCMediaDiscoverer(name: "upnp")
        XCTAssertNotNil(discoverer, "VLCMediaDiscoverer should be available")
    }
    
    func testMediaAvailable() {
        let url = URL(string: "https://example.com/test.mp4")!
        let media = VLCMedia(url: url)
        XCTAssertNotNil(media, "VLCMedia should be available")
        XCTAssertEqual(media.url, url, "VLCMedia should preserve URL")
    }
    
    func testMediaListAvailable() {
        let mediaList = VLCMediaList()
        XCTAssertNotNil(mediaList, "VLCMediaList should be available")
        XCTAssertEqual(mediaList.count, 0, "New media list should be empty")
    }
    
    func testMediaListPlayerAvailable() {
        let mediaListPlayer = VLCMediaListPlayer()
        XCTAssertNotNil(mediaListPlayer, "VLCMediaListPlayer should be available")
    }
    
    func testMediaSubitemsAvailable() {
        let url = URL(string: "file:///")!
        let media = VLCMedia(url: url)
        
        // This property should be accessible (missing in limited packages)
        let subitems = media.subitems
        XCTAssertNotNil(subitems, "Media subitems property should be available")
    }
    
    func testRendererDiscovererAvailable() {
        // Test Chromecast/AirPlay discovery capability
        let rendererDiscoverer = VLCRendererDiscoverer(name: "chromecast")
        XCTAssertNotNil(rendererDiscoverer, "VLCRendererDiscoverer should be available")
    }
    
    func testLibraryVersion() {
        let version = VLCLibrary.version
        XCTAssertNotNil(version, "VLC library version should be available")
        print("VLC Library version: \(version ?? "unknown")")
    }
    
    func testAudioFeaturesAvailable() {
        let mediaPlayer = VLCMediaPlayer()
        
        // Test audio-related APIs
        XCTAssertNotNil(mediaPlayer.audio, "Audio controls should be available")
        
        let equalizer = VLCAudioEqualizer()
        XCTAssertNotNil(equalizer, "Audio equalizer should be available")
    }
    
    func testVideoFeaturesAvailable() {
        let mediaPlayer = VLCMediaPlayer()
        
        // Test video-related APIs  
        XCTAssertNotNil(mediaPlayer.video, "Video controls should be available")
    }
    
    func testMediaParsingOptions() {
        let url = URL(string: "file:///")!
        let media = VLCMedia(url: url)
        
        // Test that parsing options are available
        // This is often missing in incomplete SPM packages
        media.parseWithOptions(.parseNetwork)
        XCTAssertTrue(true, "Parse options should be available")
    }
    
    func testDialogProvider() {
        // Test dialog provider functionality (advanced feature)
        let dialogProvider = VLCDialogProvider.shared
        XCTAssertNotNil(dialogProvider, "Dialog provider should be available")
    }
    
    // MARK: - Performance Tests
    
    func testMediaPlayerCreationPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = VLCMediaPlayer()
            }
        }
    }
    
    // MARK: - Framework Integration Tests
    
    func testFrameworkBundle() {
        let bundle = Bundle(for: VLCMediaPlayer.self)
        XCTAssertNotNil(bundle, "VLCKit bundle should be accessible")
        
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        print("VLCKit framework version: \(version ?? "unknown")")
    }
}