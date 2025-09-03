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
            targets: ["VLCKit"]
        )
    ],
    targets: [
        .target(
            name: "VLCKit",
            dependencies: ["MobileVLCKit"],
            path: "Sources/VLCKit"
        ),
        .binaryTarget(
            name: "MobileVLCKit",
            url: "https://github.com/rsalesas/VLCKit/releases/download/3.6.4/MobileVLCKit.xcframework.zip",
            checksum: "8c47c9c819a6a055828affa1d82e42cf19df986023470dad825e6d69d8af90d8"
        ),
        .testTarget(
            name: "VLCKitTests",
            dependencies: ["VLCKit"],
            path: "Tests/VLCKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)