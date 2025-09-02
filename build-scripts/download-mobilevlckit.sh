#!/bin/bash

set -e

# MobileVLCKit XCFramework Download Script
# Downloads prebuilt MobileVLCKit 3.6.0 from CocoaPods and creates XCFramework

VLCKIT_VERSION="3.6.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
TEMP_DIR="$BUILD_DIR/temp"

echo "📦 Downloading MobileVLCKit v$VLCKIT_VERSION from CocoaPods"
echo "Project root: $PROJECT_ROOT"

# Clean and create build directories
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$TEMP_DIR"

# Create temporary Xcode project and Podfile
cd "$TEMP_DIR"

# Create a minimal Xcode project
mkdir -p Temp.xcodeproj
cat > Temp.xcodeproj/project.pbxproj << EOF
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 50;
	objects = {
		1 = {isa = PBXProject; buildConfigurationList = 2; mainGroup = 3; targets = (); };
		2 = {isa = XCConfigurationList; buildConfigurations = (); };
		3 = {isa = PBXGroup; children = (); sourceTree = "<group>"; };
	};
	rootObject = 1;
}
EOF

cat > Podfile << EOF
platform :ios, '11.0'

project 'Temp.xcodeproj'

target 'Temp' do
  pod 'MobileVLCKit', '$VLCKIT_VERSION'
end
EOF

echo "🔄 Installing MobileVLCKit via CocoaPods..."
pod install --no-repo-update

# Verify the framework was downloaded
FRAMEWORK_PATH="$TEMP_DIR/Pods/MobileVLCKit/MobileVLCKit.framework"
if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "❌ MobileVLCKit.framework not found at expected location"
    echo "Looking for framework..."
    find "$TEMP_DIR/Pods" -name "*.framework" -type d
    exit 1
fi

echo "✅ MobileVLCKit.framework found"
echo "📏 Framework size: $(du -sh "$FRAMEWORK_PATH" | cut -f1)"

# Copy framework to build directory for XCFramework creation
cp -R "$FRAMEWORK_PATH" "$BUILD_DIR/"

# Create XCFramework from the iOS framework
echo "📦 Creating XCFramework..."
cd "$PROJECT_ROOT"

# For MobileVLCKit, we typically only need iOS/tvOS support
# The framework from CocoaPods should already be a universal framework
xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/MobileVLCKit.framework" \
    -output "VLCKit.xcframework"

if [ -d "VLCKit.xcframework" ]; then
    echo "✅ XCFramework created successfully!"
    echo "📏 XCFramework size: $(du -sh VLCKit.xcframework | cut -f1)"
    
    # Show framework architectures
    echo "📋 Framework architectures:"
    lipo -info "$BUILD_DIR/MobileVLCKit.framework/MobileVLCKit" || true
    
    # Show XCFramework info
    echo "📋 XCFramework info:"
    if command -v xcodebuild &> /dev/null; then
        xcodebuild -version
    fi
else
    echo "❌ Failed to create XCFramework"
    exit 1
fi

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
rm -rf "$BUILD_DIR"

echo "🎯 XCFramework ready at: $PROJECT_ROOT/VLCKit.xcframework"
echo "✅ Ready for SPM distribution!"