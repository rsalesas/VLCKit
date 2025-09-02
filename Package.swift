// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VLCKit",
    platforms: [
        .iOS(.v11),     // MobileVLCKit 3.6 supports iOS 11+
        .tvOS(.v11)     // MobileVLCKit 3.6 supports tvOS 11+ (no macOS support)
    ],
    products: [
        .library(
            name: "VLCKit",
            targets: ["VLCKitSPM"]
        )
    ],
    targets: [
        .target(
            name: "VLCKitSPM",
            dependencies: ["MobileVLCKit"],
            path: "Sources/VLCKitSPM"
        ),
        .binaryTarget(
            name: "MobileVLCKit",
            path: "MobileVLCKit.xcframework"
        ),
        .testTarget(
            name: "VLCKitSPMTests",
            dependencies: ["VLCKitSPM"],
            path: "Tests/VLCKitSPMTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)