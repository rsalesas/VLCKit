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
            path: "MobileVLCKit.xcframework"
        ),
        .testTarget(
            name: "VLCKitTests",
            dependencies: ["VLCKit"],
            path: "Tests/VLCKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)