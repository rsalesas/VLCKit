#!/bin/bash

set -e

echo "🔧 Setting up Git LFS for VLCKit-SPM"

# Check if Git LFS is installed
if ! command -v git-lfs &> /dev/null; then
    echo "📦 Installing Git LFS via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install git-lfs
    else
        echo "❌ Homebrew not found. Please install Git LFS manually:"
        echo "   Visit: https://git-lfs.github.io/"
        echo "   Or run: curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
        exit 1
    fi
fi

echo "✅ Git LFS is available"

# Initialize Git LFS in the repository
echo "🔄 Initializing Git LFS..."
git lfs install

# Track framework files
echo "📁 Setting up LFS tracking for framework files..."
git lfs track "*.xcframework"
git lfs track "*.framework" 
git lfs track "VLCKit.xcframework/**"

# Show what's being tracked
echo "📋 Files tracked by Git LFS:"
git lfs track

echo "✅ Git LFS setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Build/download the XCFramework"
echo "2. Add and commit files: git add . && git commit -m 'Initial commit'"
echo "3. Push to GitHub: git push origin main"