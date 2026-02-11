#!/bin/bash

##############################################################################
# MiniLLM iOS - Automated iPhone Deployment
#
# This script automatically:
# 1. Creates Xcode project
# 2. Adds all source files
# 3. Configures build settings
# 4. Detects your iPhone
# 5. Builds and deploys to device
#
# Usage: ./deploy_to_iphone.sh
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="MiniLLM"
BUNDLE_ID="com.minillm.app"
DEPLOYMENT_TARGET="16.0"
TEAM_ID=""  # Will auto-detect or prompt

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║          MiniLLM iOS - Automated Deployment             ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

##############################################################################
# Step 1: System Checks
##############################################################################

echo -e "${YELLOW}[1/6] Checking system requirements...${NC}"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script must be run on macOS${NC}"
    echo ""
    echo "You're currently on: $OSTYPE"
    echo ""
    echo "📋 Instructions for Linux/Windows users:"
    echo "1. Transfer this folder to a Mac"
    echo "2. Run this script on the Mac"
    echo ""
    echo "Transfer methods:"
    echo "  • USB drive"
    echo "  • AirDrop"
    echo "  • Cloud storage (Dropbox, Google Drive)"
    echo "  • SCP: scp -r MiniLLM-iOS/ user@your-mac.local:~/Desktop/"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed${NC}"
    echo "Please install Xcode from the App Store:"
    echo "https://apps.apple.com/app/xcode/id497799835"
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo -e "${GREEN}✓ Xcode $XCODE_VERSION found${NC}"

# Check for command-line tools
if ! xcode-select -p &> /dev/null; then
    echo -e "${YELLOW}⚠ Installing Xcode Command Line Tools...${NC}"
    xcode-select --install
    echo "Please complete the installation and run this script again"
    exit 1
fi

echo -e "${GREEN}✓ Xcode Command Line Tools installed${NC}"

##############################################################################
# Step 2: Detect iPhone
##############################################################################

echo ""
echo -e "${YELLOW}[2/6] Detecting connected iPhone...${NC}"

# Get list of connected devices
DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v "Simulator" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ No iPhone detected${NC}"
    echo ""
    echo "Please:"
    echo "1. Connect your iPhone via USB cable"
    echo "2. Unlock your iPhone"
    echo "3. Trust this computer (tap 'Trust' when prompted)"
    echo "4. Run this script again"
    echo ""
    echo "Alternative: Run on Simulator (automatic)"
    read -p "Run on Simulator instead? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DEVICE_ID="simulator"
        DEVICE_NAME="iPhone 15 Pro"
        echo -e "${GREEN}✓ Will use Simulator: $DEVICE_NAME${NC}"
    else
        exit 1
    fi
else
    echo -e "${GREEN}✓ iPhone(s) detected:${NC}"
    echo "$DEVICES"
    echo ""

    # Get first device ID
    DEVICE_ID=$(echo "$DEVICES" | head -n 1 | sed -n 's/.*(\([^)]*\)).*/\1/p')
    DEVICE_NAME=$(echo "$DEVICES" | head -n 1 | sed 's/ (.*//')

    echo -e "${GREEN}✓ Selected: $DEVICE_NAME${NC}"
    echo -e "${BLUE}Device ID: $DEVICE_ID${NC}"
fi

##############################################################################
# Step 3: Auto-detect or Set Development Team
##############################################################################

echo ""
echo -e "${YELLOW}[3/6] Configuring development team...${NC}"

# Try to get team ID from existing Xcode preferences
TEAM_ID=$(defaults read com.apple.dt.Xcode IDEProvisioningTeamManagerLastSelectedTeamID 2>/dev/null || echo "")

if [ -z "$TEAM_ID" ]; then
    # List available teams
    echo "Available development teams:"
    security find-identity -v -p codesigning | grep "Apple Development" || echo "No teams found"
    echo ""
    echo "⚠️  You need an Apple Developer account (free account works)"
    echo ""
    echo "To set up:"
    echo "1. Open Xcode"
    echo "2. Go to Settings → Accounts"
    echo "3. Sign in with your Apple ID"
    echo "4. Run this script again"
    echo ""
    read -p "Enter your Team ID (or press Enter to open Xcode): " INPUT_TEAM_ID

    if [ -z "$INPUT_TEAM_ID" ]; then
        open -a Xcode
        echo "After signing in to Xcode, run this script again"
        exit 0
    else
        TEAM_ID="$INPUT_TEAM_ID"
    fi
fi

echo -e "${GREEN}✓ Team ID: $TEAM_ID${NC}"

##############################################################################
# Step 4: Create Xcode Project
##############################################################################

echo ""
echo -e "${YELLOW}[4/6] Creating Xcode project...${NC}"

# Clean up any existing project
if [ -d "$PROJECT_NAME.xcodeproj" ]; then
    echo "Removing existing project..."
    rm -rf "$PROJECT_NAME.xcodeproj"
fi

if [ -d "build" ]; then
    rm -rf build
fi

# Create project directory structure
mkdir -p "$PROJECT_NAME"

# Copy all source files to project directory
echo "Copying source files..."
cp -r MiniLLM-iOS/* "$PROJECT_NAME/"

# Create a minimal Xcode project using xcodebuild
# We'll create a project.pbxproj file programmatically

PROJECT_DIR="$PROJECT_NAME.xcodeproj"
mkdir -p "$PROJECT_DIR"

# Generate project.pbxproj
cat > "$PROJECT_DIR/project.pbxproj" << 'PBXPROJ_END'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		AA0001 /* MiniLLMApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0002; };
		AA0003 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0004; };
		AA0005 /* LLMModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0006; };
		AA0007 /* ModelManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0008; };
		AA0009 /* ServerManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0010; };
		AA0011 /* ModelsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0012; };
		AA0013 /* ChatView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0014; };
		AA0015 /* TrainingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0016; };
		AA0017 /* ServerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0018; };
		AA0019 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0020; };
		AA0021 /* ModelDownloadService.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0022; };
		AA0023 /* InferenceService.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0024; };
		AA0025 /* TrainingService.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0026; };
		AA0027 /* ServerService.swift in Sources */ = {isa = PBXBuildFile; fileRef = AA0028; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		AA0002 /* MiniLLMApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MiniLLMApp.swift; sourceTree = "<group>"; };
		AA0004 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		AA0006 /* LLMModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LLMModel.swift; sourceTree = "<group>"; };
		AA0008 /* ModelManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelManager.swift; sourceTree = "<group>"; };
		AA0010 /* ServerManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerManager.swift; sourceTree = "<group>"; };
		AA0012 /* ModelsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelsView.swift; sourceTree = "<group>"; };
		AA0014 /* ChatView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatView.swift; sourceTree = "<group>"; };
		AA0016 /* TrainingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TrainingView.swift; sourceTree = "<group>"; };
		AA0018 /* ServerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerView.swift; sourceTree = "<group>"; };
		AA0020 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		AA0022 /* ModelDownloadService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelDownloadService.swift; sourceTree = "<group>"; };
		AA0024 /* InferenceService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = InferenceService.swift; sourceTree = "<group>"; };
		AA0026 /* TrainingService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TrainingService.swift; sourceTree = "<group>"; };
		AA0028 /* ServerService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerService.swift; sourceTree = "<group>"; };
		AA9999 /* MiniLLM.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MiniLLM.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		AA1000 = {
			isa = PBXGroup;
			children = (
				AA0002 /* MiniLLMApp.swift */,
				AA0004 /* ContentView.swift */,
				AA1001 /* Models */,
				AA1002 /* ViewModels */,
				AA1003 /* Views */,
				AA1004 /* Services */,
			);
			path = MiniLLM;
			sourceTree = "<group>";
		};
		AA1001 /* Models */ = {
			isa = PBXGroup;
			children = (
				AA0006 /* LLMModel.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		AA1002 /* ViewModels */ = {
			isa = PBXGroup;
			children = (
				AA0008 /* ModelManager.swift */,
				AA0010 /* ServerManager.swift */,
			);
			path = ViewModels;
			sourceTree = "<group>";
		};
		AA1003 /* Views */ = {
			isa = PBXGroup;
			children = (
				AA0012 /* ModelsView.swift */,
				AA0014 /* ChatView.swift */,
				AA0016 /* TrainingView.swift */,
				AA0018 /* ServerView.swift */,
				AA0020 /* SettingsView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		};
		AA1004 /* Services */ = {
			isa = PBXGroup;
			children = (
				AA0022 /* ModelDownloadService.swift */,
				AA0024 /* InferenceService.swift */,
				AA0026 /* TrainingService.swift */,
				AA0028 /* ServerService.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		AA2000 = {
			isa = PBXGroup;
			children = (
				AA1000,
				AA2001 /* Products */,
			);
			sourceTree = "<group>";
		};
		AA2001 /* Products */ = {
			isa = PBXGroup;
			children = (
				AA9999 /* MiniLLM.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		AA3000 /* MiniLLM */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = AA4000 /* Build configuration list for PBXNativeTarget "MiniLLM" */;
			buildPhases = (
				AA5000 /* Sources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MiniLLM;
			productName = MiniLLM;
			productReference = AA9999 /* MiniLLM.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		AA6000 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					AA3000 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = AA7000 /* Build configuration list for PBXProject "MiniLLM" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = AA2000;
			productRefGroup = AA2001 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				AA3000 /* MiniLLM */,
			);
		};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		AA5000 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AA0001 /* MiniLLMApp.swift in Sources */,
				AA0003 /* ContentView.swift in Sources */,
				AA0005 /* LLMModel.swift in Sources */,
				AA0007 /* ModelManager.swift in Sources */,
				AA0009 /* ServerManager.swift in Sources */,
				AA0011 /* ModelsView.swift in Sources */,
				AA0013 /* ChatView.swift in Sources */,
				AA0015 /* TrainingView.swift in Sources */,
				AA0017 /* ServerView.swift in Sources */,
				AA0019 /* SettingsView.swift in Sources */,
				AA0021 /* ModelDownloadService.swift in Sources */,
				AA0023 /* InferenceService.swift in Sources */,
				AA0025 /* TrainingService.swift in Sources */,
				AA0027 /* ServerService.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		AA8000 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		AA8001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		AA9000 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = TEAM_ID_PLACEHOLDER;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "../Info.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.minillm.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		AA9001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = TEAM_ID_PLACEHOLDER;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "../Info.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.minillm.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		AA4000 /* Build configuration list for PBXNativeTarget "MiniLLM" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				AA9000 /* Debug */,
				AA9001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		AA7000 /* Build configuration list for PBXProject "MiniLLM" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				AA8000 /* Debug */,
				AA8001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = AA6000 /* Project object */;
}
PBXPROJ_END

# Replace TEAM_ID placeholder with actual team ID
sed -i '' "s/TEAM_ID_PLACEHOLDER/$TEAM_ID/g" "$PROJECT_DIR/project.pbxproj"

echo -e "${GREEN}✓ Xcode project created${NC}"

##############################################################################
# Step 5: Build the App
##############################################################################

echo ""
echo -e "${YELLOW}[5/6] Building app...${NC}"

# Build for device or simulator
if [ "$DEVICE_ID" = "simulator" ]; then
    # Build for simulator
    DESTINATION="platform=iOS Simulator,name=$DEVICE_NAME"
    SDK="iphonesimulator"
else
    # Build for device
    DESTINATION="platform=iOS,id=$DEVICE_ID"
    SDK="iphoneos"
fi

echo "Building for: $DESTINATION"

xcodebuild clean build \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -destination "$DESTINATION" \
    -sdk "$SDK" \
    -configuration Debug \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee build.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    echo "Check build.log for details"
    exit 1
fi

echo -e "${GREEN}✓ Build successful${NC}"

##############################################################################
# Step 6: Deploy to iPhone
##############################################################################

echo ""
echo -e "${YELLOW}[6/6] Deploying to iPhone...${NC}"

# Find the built app
APP_PATH=$(find build -name "$PROJECT_NAME.app" | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app${NC}"
    exit 1
fi

if [ "$DEVICE_ID" = "simulator" ]; then
    # Boot simulator if not running
    xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
    sleep 2

    # Install app
    xcrun simctl install "$DEVICE_NAME" "$APP_PATH"

    # Launch app
    BUNDLE_ID="com.minillm.app"
    xcrun simctl launch "$DEVICE_NAME" "$BUNDLE_ID"

    # Open simulator window
    open -a Simulator

    echo -e "${GREEN}✓ App launched in Simulator!${NC}"
else
    # Install on device using ios-deploy or xcrun
    if command -v ios-deploy &> /dev/null; then
        ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --justlaunch
    else
        echo "Installing ios-deploy for device deployment..."
        brew install ios-deploy
        ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --justlaunch
    fi

    echo -e "${GREEN}✓ App installed on iPhone!${NC}"
fi

##############################################################################
# Success!
##############################################################################

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║                    🎉 SUCCESS! 🎉                       ║"
echo "║                                                          ║"
echo "║           MiniLLM is now running on your iPhone!         ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open MiniLLM app on your iPhone/Simulator"
echo "2. Go to Models tab → Download → Load a model"
echo "3. Chat tab → Start chatting!"
echo "4. Training tab → Create datasets"
echo "5. Server tab → Start API server"
echo ""
echo -e "${YELLOW}Note: App uses simulated inference by default${NC}"
echo "For real AI responses, integrate llama.cpp (see SETUP_GUIDE.md)"
echo ""
echo -e "${GREEN}Enjoy MiniLLM! 🚀${NC}"
echo ""
