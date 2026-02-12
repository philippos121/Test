#!/bin/bash

# Create complete Xcode project for MiniLLM iOS
# This script generates a proper .xcodeproj structure

set -e

echo "🔨 Creating Xcode Project for MiniLLM..."

PROJECT_NAME="MiniLLM"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$PROJECT_DIR/MiniLLM-iOS"
XCODE_PROJ="$PROJECT_DIR/$PROJECT_NAME.xcodeproj"

echo "📁 Project directory: $PROJECT_DIR"
echo "📁 Source directory: $SOURCE_DIR"

# Create project directory
mkdir -p "$XCODE_PROJ"

# Generate unique UUIDs for project structure
generate_uuid() {
    uuidgen | tr '[:lower:]' '[:upper:]' | tr -d '-' | cut -c1-24
}

PROJ_UUID=$(generate_uuid)
MAIN_GROUP_UUID=$(generate_uuid)
PRODUCTS_GROUP_UUID=$(generate_uuid)
TARGET_UUID=$(generate_uuid)
NATIVE_TARGET_UUID=$(generate_uuid)
BUILD_CONFIG_LIST_UUID=$(generate_uuid)
DEBUG_CONFIG_UUID=$(generate_uuid)
RELEASE_CONFIG_UUID=$(generate_uuid)
BUILD_PHASE_SOURCES_UUID=$(generate_uuid)
BUILD_PHASE_FRAMEWORKS_UUID=$(generate_uuid)
BUILD_PHASE_RESOURCES_UUID=$(generate_uuid)
PRODUCT_REF_UUID=$(generate_uuid)

# Collect all Swift files
echo "📦 Collecting source files..."
SWIFT_FILES=()
FILE_REFS=()

find "$SOURCE_DIR" -name "*.swift" -type f | while read -r file; do
    rel_path="${file#$SOURCE_DIR/}"
    echo "  - $rel_path"
done

# Create project.pbxproj
echo "📝 Generating project.pbxproj..."

cat > "$XCODE_PROJ/project.pbxproj" << 'PBXPROJ_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		FILE001 /* MiniLLMApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF001 /* MiniLLMApp.swift */; };
		FILE002 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF002 /* ContentView.swift */; };
		FILE003 /* LLMModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF003 /* LLMModel.swift */; };
		FILE004 /* ModelManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF004 /* ModelManager.swift */; };
		FILE005 /* ServerManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF005 /* ServerManager.swift */; };
		FILE006 /* InferenceService.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF006 /* InferenceService.swift */; };
		FILE007 /* ModelDownloadService.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF007 /* ModelDownloadService.swift */; };
		FILE008 /* TrainingService.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF008 /* TrainingService.swift */; };
		FILE009 /* ServerService.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF009 /* ServerService.swift */; };
		FILE010 /* LlamaCppBridge.mm in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF010 /* LlamaCppBridge.mm */; };
		FILE011 /* ModelsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF011 /* ModelsView.swift */; };
		FILE012 /* ChatView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF012 /* ChatView.swift */; };
		FILE013 /* TrainingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF013 /* TrainingView.swift */; };
		FILE014 /* ServerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF014 /* ServerView.swift */; };
		FILE015 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = FILEREF015 /* SettingsView.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		FILEREF001 /* MiniLLMApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MiniLLMApp.swift; sourceTree = "<group>"; };
		FILEREF002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		FILEREF003 /* LLMModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LLMModel.swift; sourceTree = "<group>"; };
		FILEREF004 /* ModelManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelManager.swift; sourceTree = "<group>"; };
		FILEREF005 /* ServerManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerManager.swift; sourceTree = "<group>"; };
		FILEREF006 /* InferenceService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = InferenceService.swift; sourceTree = "<group>"; };
		FILEREF007 /* ModelDownloadService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelDownloadService.swift; sourceTree = "<group>"; };
		FILEREF008 /* TrainingService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TrainingService.swift; sourceTree = "<group>"; };
		FILEREF009 /* ServerService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerService.swift; sourceTree = "<group>"; };
		FILEREF010 /* LlamaCppBridge.mm */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.objcpp; path = LlamaCppBridge.mm; sourceTree = "<group>"; };
		FILEREF011 /* ModelsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModelsView.swift; sourceTree = "<group>"; };
		FILEREF012 /* ChatView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatView.swift; sourceTree = "<group>"; };
		FILEREF013 /* TrainingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TrainingView.swift; sourceTree = "<group>"; };
		FILEREF014 /* ServerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerView.swift; sourceTree = "<group>"; };
		FILEREF015 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		FILEREF016 /* LlamaCppBridge.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = LlamaCppBridge.h; sourceTree = "<group>"; };
		FILEREF017 /* MiniLLM-Bridging-Header.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = "MiniLLM-Bridging-Header.h"; sourceTree = "<group>"; };
		FILEREF018 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		PRODUCT001 /* MiniLLM.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MiniLLM.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		FRAMEWORKS001 = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		GROUP_MAIN = {
			isa = PBXGroup;
			children = (
				GROUP_MINILLM /* MiniLLM */,
				GROUP_PRODUCTS /* Products */,
			);
			sourceTree = "<group>";
		};
		GROUP_MINILLM = {
			isa = PBXGroup;
			children = (
				FILEREF001 /* MiniLLMApp.swift */,
				FILEREF002 /* ContentView.swift */,
				GROUP_MODELS /* Models */,
				GROUP_VIEWS /* Views */,
				GROUP_VIEWMODELS /* ViewModels */,
				GROUP_SERVICES /* Services */,
				FILEREF017 /* MiniLLM-Bridging-Header.h */,
				FILEREF018 /* Info.plist */,
			);
			path = "MiniLLM-iOS";
			sourceTree = "<group>";
		};
		GROUP_MODELS = {
			isa = PBXGroup;
			children = (
				FILEREF003 /* LLMModel.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		GROUP_VIEWS = {
			isa = PBXGroup;
			children = (
				FILEREF011 /* ModelsView.swift */,
				FILEREF012 /* ChatView.swift */,
				FILEREF013 /* TrainingView.swift */,
				FILEREF014 /* ServerView.swift */,
				FILEREF015 /* SettingsView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		};
		GROUP_VIEWMODELS = {
			isa = PBXGroup;
			children = (
				FILEREF004 /* ModelManager.swift */,
				FILEREF005 /* ServerManager.swift */,
			);
			path = ViewModels;
			sourceTree = "<group>";
		};
		GROUP_SERVICES = {
			isa = PBXGroup;
			children = (
				FILEREF006 /* InferenceService.swift */,
				FILEREF007 /* ModelDownloadService.swift */,
				FILEREF008 /* TrainingService.swift */,
				FILEREF009 /* ServerService.swift */,
				FILEREF010 /* LlamaCppBridge.mm */,
				FILEREF016 /* LlamaCppBridge.h */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		GROUP_PRODUCTS = {
			isa = PBXGroup;
			children = (
				PRODUCT001 /* MiniLLM.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		TARGET001 = {
			isa = PBXNativeTarget;
			buildConfigurationList = CONFIGLIST001;
			buildPhases = (
				SOURCES001 /* Sources */,
				FRAMEWORKS001 /* Frameworks */,
				RESOURCES001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MiniLLM;
			productName = MiniLLM;
			productReference = PRODUCT001 /* MiniLLM.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		PROJECT001 = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					TARGET001 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = CONFIGLIST002;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = GROUP_MAIN;
			productRefGroup = GROUP_PRODUCTS;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				TARGET001 /* MiniLLM */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		RESOURCES001 = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		SOURCES001 = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				FILE001 /* MiniLLMApp.swift in Sources */,
				FILE002 /* ContentView.swift in Sources */,
				FILE003 /* LLMModel.swift in Sources */,
				FILE004 /* ModelManager.swift in Sources */,
				FILE005 /* ServerManager.swift in Sources */,
				FILE006 /* InferenceService.swift in Sources */,
				FILE007 /* ModelDownloadService.swift in Sources */,
				FILE008 /* TrainingService.swift in Sources */,
				FILE009 /* ServerService.swift in Sources */,
				FILE010 /* LlamaCppBridge.mm in Sources */,
				FILE011 /* ModelsView.swift in Sources */,
				FILE012 /* ChatView.swift in Sources */,
				FILE013 /* TrainingView.swift in Sources */,
				FILE014 /* ServerView.swift in Sources */,
				FILE015 /* SettingsView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		CONFIG_DEBUG = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
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
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
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
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "MiniLLM-iOS/Info.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.minillm.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "MiniLLM-iOS/MiniLLM-Bridging-Header.h";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		CONFIG_RELEASE = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
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
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				DEVELOPMENT_TEAM = "";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_PREVIEWS = YES;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "MiniLLM-iOS/Info.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.minillm.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "MiniLLM-iOS/MiniLLM-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		CONFIG_PROJECT_DEBUG = {
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
				GCC_C_LANGUAGE_STANDARD = gnu17;
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
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		CONFIG_PROJECT_RELEASE = {
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
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		CONFIGLIST001 = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CONFIG_DEBUG /* Debug */,
				CONFIG_RELEASE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		CONFIGLIST002 = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CONFIG_PROJECT_DEBUG /* Debug */,
				CONFIG_PROJECT_RELEASE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = PROJECT001 /* Project object */;
}
PBXPROJ_EOF

echo "✅ project.pbxproj created"

# Create xcschememanagement.plist
mkdir -p "$XCODE_PROJ/xcshareddata/xcschemes"
mkdir -p "$XCODE_PROJ/xcuserdata/$USER.xcuserdatad/xcschemes"

cat > "$XCODE_PROJ/xcshareddata/xcschemes/MiniLLM.xcscheme" << 'SCHEME_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "TARGET001"
               BuildableName = "MiniLLM.app"
               BlueprintName = "MiniLLM"
               ReferencedContainer = "container:MiniLLM.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "TARGET001"
            BuildableName = "MiniLLM.app"
            BlueprintName = "MiniLLM"
            ReferencedContainer = "container:MiniLLM.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "TARGET001"
            BuildableName = "MiniLLM.app"
            BlueprintName = "MiniLLM"
            ReferencedContainer = "container:MiniLLM.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME_EOF

cat > "$XCODE_PROJ/xcuserdata/$USER.xcuserdatad/xcschemes/xcschememanagement.plist" << 'SCHEMEMGMT_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SchemeUserState</key>
	<dict>
		<key>MiniLLM.xcscheme_^#shared#^_</key>
		<dict>
			<key>orderHint</key>
			<integer>0</integer>
		</dict>
	</dict>
</dict>
</plist>
SCHEMEMGMT_EOF

echo "✅ Xcode schemes created"

# Create workspace settings
mkdir -p "$XCODE_PROJ/project.xcworkspace"
cat > "$XCODE_PROJ/project.xcworkspace/contents.xcworkspacedata" << 'WORKSPACE_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
WORKSPACE_EOF

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║           ✅ Xcode Project Created! ✅                 ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Project: $PROJECT_NAME.xcodeproj"
echo "📁 Location: $PROJECT_DIR"
echo ""
echo "🚀 Next steps:"
echo "  1. Open: open $PROJECT_NAME.xcodeproj"
echo "  2. Connect iPhone or select Simulator"
echo "  3. Press ⌘R to build and run"
echo ""
echo "🔧 To add llama.cpp:"
echo "  1. See MiniLLM-iOS/SETUP_GUIDE.md"
echo "  2. Build llama.cpp for iOS"
echo "  3. Link libllama.a in Build Phases"
echo ""
