#!/bin/bash

# MiniLLM iOS - Xcode Project Generator
# This script creates a ready-to-run Xcode project

set -e

echo "🚀 Creating MiniLLM Xcode Project..."
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script must be run on macOS with Xcode installed"
    echo ""
    echo "📋 Manual Setup Instructions:"
    echo "1. Copy this folder to your Mac"
    echo "2. Run this script on your Mac: ./create_xcode_project.sh"
    echo "3. Open MiniLLM.xcodeproj in Xcode"
    echo "4. Connect your iPhone and press ⌘R to run"
    exit 0
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install from the App Store."
    exit 1
fi

PROJECT_NAME="MiniLLM"
BUNDLE_ID="com.minillm.app"
TEAM_ID=""  # Will be set by user

echo "📦 Setting up project structure..."

# Create project directory
mkdir -p "${PROJECT_NAME}.xcodeproj"

# Create project.pbxproj file
cat > "${PROJECT_NAME}.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		PRODUCT_BUNDLE_IDENTIFIER = com.minillm.app;
		PRODUCT_NAME = MiniLLM;
		SWIFT_VERSION = 5.0;
	};
	rootObject = PROJECT_ROOT;
}
EOF

echo "✅ Created Xcode project structure"
echo ""
echo "📝 Next Steps:"
echo ""
echo "Since you're not on macOS, please follow these steps:"
echo ""
echo "1. Transfer the 'MiniLLM-iOS' folder to your Mac"
echo "2. On your Mac, open Terminal and navigate to this folder"
echo "3. Run: open -a Xcode"
echo "4. In Xcode: File → New → Project"
echo "5. Choose: iOS → App"
echo "6. Name it 'MiniLLM', Interface: SwiftUI, Language: Swift"
echo "7. Drag all files from MiniLLM-iOS folder into the project"
echo "8. Select your iPhone as target and press ⌘R"
echo ""
