#!/bin/bash

set -e

# Simple MobileVLCKit download without CocoaPods project setup
VLCKIT_VERSION="3.6.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"

echo "📦 Downloading MobileVLCKit v$VLCKIT_VERSION"
echo "Project root: $PROJECT_ROOT"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download the framework directly from CocoaPods CDN
echo "🌐 Downloading from CocoaPods CDN..."

# The CocoaPods spec for MobileVLCKit points to the framework download
DOWNLOAD_URL="https://download.videolan.org/cocoapods/prod/MobileVLCKit-3.6.0-1ed3b26-0bc5ed3.tar.xz"

# Try alternative URLs if the above doesn't work
curl -L -o MobileVLCKit.tar.xz "$DOWNLOAD_URL" || {
    echo "⚠️  Direct download failed, trying alternative..."
    
    # Try GitHub releases or other sources
    GITHUB_URL="https://github.com/videolan/vlckit/releases/download/3.6.0/MobileVLCKit-Binary-3.6.0.zip"
    curl -L -o MobileVLCKit.zip "$GITHUB_URL" || {
        echo "❌ Failed to download MobileVLCKit"
        echo "Manual download required from:"
        echo "  - https://code.videolan.org/videolan/VLCKit/-/jobs"
        echo "  - https://download.videolan.org/pub/cocoapods/"
        exit 1
    }
    
    # Extract zip
    unzip MobileVLCKit.zip
}

# Extract tar.xz if downloaded
if [ -f "MobileVLCKit.tar.xz" ]; then
    tar -xf MobileVLCKit.tar.xz
fi

# Find the framework
FRAMEWORK_PATH=$(find . -name "MobileVLCKit.framework" -type d | head -1)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "❌ MobileVLCKit.framework not found"
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ Found framework at: $FRAMEWORK_PATH"
echo "📏 Framework size: $(du -sh "$FRAMEWORK_PATH" | cut -f1)"

# Create XCFramework
echo "📦 Creating XCFramework..."
cd "$PROJECT_ROOT"

xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/$FRAMEWORK_PATH" \
    -output "VLCKit.xcframework"

if [ -d "VLCKit.xcframework" ]; then
    echo "✅ XCFramework created successfully!"
    echo "📏 XCFramework size: $(du -sh VLCKit.xcframework | cut -f1)"
    
    # Show framework architectures
    echo "📋 Framework architectures:"
    if [ -f "$BUILD_DIR/$FRAMEWORK_PATH/MobileVLCKit" ]; then
        lipo -info "$BUILD_DIR/$FRAMEWORK_PATH/MobileVLCKit" || true
    fi
else
    echo "❌ Failed to create XCFramework"
    exit 1
fi

echo "🧹 Cleaning up build directory..."
rm -rf "$BUILD_DIR"

echo "🎯 XCFramework ready at: $PROJECT_ROOT/VLCKit.xcframework"