#!/bin/bash

set -e

# VLCKit XCFramework Build Script
# This script clones VLCKit source and builds an XCFramework for SPM distribution

VLCKIT_VERSION="3.6.0"
COCOAPODS_SPEC="MobileVLCKit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
VLCKIT_SOURCE_DIR="$BUILD_DIR/vlckit-source"

echo "🔨 Building VLCKit XCFramework v$VLCKIT_VERSION"
echo "Project root: $PROJECT_ROOT"
echo "Build directory: $BUILD_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clone VLCKit source
echo "📥 Cloning VLCKit source..."
git clone https://code.videolan.org/videolan/VLCKit.git "$VLCKIT_SOURCE_DIR"
cd "$VLCKIT_SOURCE_DIR"

# Checkout specific version
echo "🏷️  Checking out version $VLCKIT_VERSION..."
git checkout "$VLCKIT_VERSION" || {
    echo "❌ Failed to checkout version $VLCKIT_VERSION"
    echo "Available tags:"
    git tag | grep "3.6" | sort -V
    exit 1
}

# Build for iOS/tvOS
echo "🍎 Building MobileVLCKit..."
./buildMobileVLCKit.sh -f

# Check if build succeeded
if [ ! -d "build/MobileVLCKit.framework" ]; then
    echo "❌ MobileVLCKit build failed"
    exit 1
fi

# Build for macOS
echo "🖥️  Building macOS VLCKit..."
./buildMacOSVLCKit.sh -f

# Check if macOS build succeeded
if [ ! -d "build/VLCKit.framework" ]; then
    echo "❌ macOS VLCKit build failed"
    exit 1
fi

# Create XCFramework
echo "📦 Creating XCFramework..."
cd "$PROJECT_ROOT"

xcodebuild -create-xcframework \
    -framework "$VLCKIT_SOURCE_DIR/build/MobileVLCKit.framework" \
    -framework "$VLCKIT_SOURCE_DIR/build/VLCKit.framework" \
    -output "VLCKit.xcframework"

if [ -d "VLCKit.xcframework" ]; then
    echo "✅ XCFramework created successfully!"
    echo "📏 Size: $(du -sh VLCKit.xcframework | cut -f1)"
    
    # Show framework info
    echo "📋 Framework info:"
    xcodebuild -version
    xcrun --show-sdk-version --sdk iphoneos
    xcrun --show-sdk-version --sdk macosx
else
    echo "❌ Failed to create XCFramework"
    exit 1
fi

# Clean up build directory but keep the source for reference
echo "🧹 Build complete!"
echo "ℹ️  VLCKit source preserved at: $VLCKIT_SOURCE_DIR"
echo "🎯 XCFramework location: $PROJECT_ROOT/VLCKit.xcframework"