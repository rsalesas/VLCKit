#!/bin/bash

set -e

VLCKIT_VERSION="3.6.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
TEMP_DIR="$BUILD_DIR/cocoapods-temp"

echo "📦 Setting up CocoaPods project for MobileVLCKit v$VLCKIT_VERSION"

# Clean and create directories
rm -rf "$BUILD_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Create a directory for our CocoaPods setup
mkdir -p TempApp
cd TempApp

# Create Podfile only (no Xcode project needed for pod spec)
cat > Podfile << EOF
platform :ios, '11.0'
install! 'cocoapods', :integrate_targets => false

target 'TempApp' do
  pod 'MobileVLCKit', '$VLCKIT_VERSION'
end
EOF

echo "🔄 Installing MobileVLCKit via CocoaPods..."
echo "This will download the framework to Pods/ directory"

# Install pods without integration
pod install --no-repo-update --verbose

# Find the framework
FRAMEWORK_PATH="Pods/MobileVLCKit"

if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "❌ MobileVLCKit not found in Pods directory"
    echo "Available directories in Pods:"
    ls -la Pods/ || echo "No Pods directory found"
    exit 1
fi

echo "✅ Found MobileVLCKit in Pods"
ls -la "$FRAMEWORK_PATH"

# Find the actual framework
ACTUAL_FRAMEWORK=$(find "$FRAMEWORK_PATH" -name "MobileVLCKit.framework" -type d | head -1)

if [ -z "$ACTUAL_FRAMEWORK" ]; then
    echo "❌ MobileVLCKit.framework not found"
    echo "Contents of MobileVLCKit pod:"
    find "$FRAMEWORK_PATH" -type f -name "*" | head -20
    exit 1
fi

echo "✅ Found framework: $ACTUAL_FRAMEWORK"
echo "📏 Framework size: $(du -sh "$ACTUAL_FRAMEWORK" | cut -f1)"

# Copy to build directory
cp -R "$ACTUAL_FRAMEWORK" "$BUILD_DIR/"

# Create XCFramework
echo "📦 Creating XCFramework..."
cd "$PROJECT_ROOT"

xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/MobileVLCKit.framework" \
    -output "VLCKit.xcframework"

if [ -d "VLCKit.xcframework" ]; then
    echo "✅ XCFramework created successfully!"
    echo "📏 XCFramework size: $(du -sh VLCKit.xcframework | cut -f1)"
    
    # Show framework architectures
    if [ -f "$BUILD_DIR/MobileVLCKit.framework/MobileVLCKit" ]; then
        echo "📋 Framework architectures:"
        lipo -info "$BUILD_DIR/MobileVLCKit.framework/MobileVLCKit" || true
    fi
else
    echo "❌ Failed to create XCFramework"
    exit 1
fi

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$BUILD_DIR"

echo "🎯 XCFramework ready at: $PROJECT_ROOT/VLCKit.xcframework"