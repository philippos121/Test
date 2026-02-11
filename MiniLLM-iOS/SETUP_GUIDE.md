# MiniLLM iOS - Complete Setup Guide

This guide walks you through setting up MiniLLM from scratch.

## Prerequisites

Before starting, ensure you have:

- [ ] **Mac** running macOS Ventura (13.0) or later
- [ ] **Xcode 15.0+** installed from the App Store
- [ ] **iPhone** running iOS 16.0+ OR iPhone Simulator
- [ ] **Apple Developer Account** (free account works for testing)
- [ ] **At least 10GB free disk space**

---

## Step 1: Create Xcode Project

### 1.1 Open Xcode

Launch Xcode and select **Create New Project**

### 1.2 Choose Template

1. Select **iOS** → **App**
2. Click **Next**

### 1.3 Configure Project

- **Product Name**: `MiniLLM`
- **Team**: Select your Apple Developer team
- **Organization Identifier**: `com.yourname` (or your domain)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None
- Click **Next** and choose save location

### 1.4 Set Deployment Target

1. Select project in navigator
2. Under **General** → **Deployment Info**
3. Set **Minimum Deployments** to **iOS 16.0**

---

## Step 2: Add Source Files

### 2.1 Create Folder Structure

In Xcode, create these groups (folders):

```
MiniLLM/
├── Models/
├── Views/
├── ViewModels/
└── Services/
```

Right-click on project → **New Group**

### 2.2 Add Files from Repository

Copy all `.swift` files from the repository into their respective folders:

**From this repository** → **To Xcode project:**

```
Models/LLMModel.swift          → MiniLLM/Models/
Views/ModelsView.swift         → MiniLLM/Views/
Views/ChatView.swift           → MiniLLM/Views/
Views/TrainingView.swift       → MiniLLM/Views/
Views/ServerView.swift         → MiniLLM/Views/
Views/SettingsView.swift       → MiniLLM/Views/
ViewModels/ModelManager.swift  → MiniLLM/ViewModels/
ViewModels/ServerManager.swift → MiniLLM/ViewModels/
Services/ModelDownloadService.swift → MiniLLM/Services/
Services/InferenceService.swift     → MiniLLM/Services/
Services/TrainingService.swift      → MiniLLM/Services/
Services/ServerService.swift        → MiniLLM/Services/
```

### 2.3 Replace Default Files

Replace these auto-generated files:
- Delete `ContentView.swift` (if exists)
- Use `MiniLLMApp.swift` instead of default `MiniLLMApp.swift`
- Add `ContentView.swift` from repository

---

## Step 3: Configure Info.plist

### 3.1 Add Required Keys

1. Select `Info.plist` in project navigator
2. Add these entries:

**Network Access:**
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>MiniLLM needs local network access to run the API server</string>

<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

**App Display Name:**
```xml
<key>CFBundleDisplayName</key>
<string>MiniLLM</string>
```

### 3.2 Enable Capabilities

1. Select project → Target **MiniLLM**
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add: **Background Modes** → Check **Network Extension**

---

## Step 4: Integrate llama.cpp

This is the most complex step. Choose one method:

### Method A: Pre-built Framework (Easiest)

1. Download pre-built llama.cpp framework:
   ```bash
   # This is a placeholder - you'd need to build or find a pre-built version
   ```

2. Drag `llama.framework` into Xcode project
3. Embed & Sign: **Embed & Sign**

### Method B: Swift Package Manager (Recommended)

**Note:** As of 2026, check if llama.cpp has official Swift package:

1. File → Add Package Dependencies
2. Search: `https://github.com/ggerganov/llama.cpp`
3. Add to project

If no Swift package exists, see Method C.

### Method C: Build from Source (Advanced)

#### 4.1 Clone llama.cpp

```bash
cd ~/Projects
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
```

#### 4.2 Build for iOS Simulator (for testing)

```bash
mkdir build-sim
cd build-sim

cmake .. \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DLLAMA_METAL=OFF \
  -DBUILD_SHARED_LIBS=OFF

make -j8
```

#### 4.3 Build for iOS Device

```bash
cd ..
mkdir build-ios
cd build-ios

cmake .. \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DLLAMA_METAL=ON \
  -DBUILD_SHARED_LIBS=OFF

make -j8
```

#### 4.4 Create Objective-C++ Bridge

Create `LlamaCppBridge.h` in Xcode:

```objc
#import <Foundation/Foundation.h>

@interface LlamaCppBridge : NSObject

+ (nullable void *)loadModelWithPath:(nonnull NSString *)path;
+ (nonnull NSString *)generateWithContext:(nonnull void *)context
                                   prompt:(nonnull NSString *)prompt
                                maxTokens:(int)maxTokens
                              temperature:(float)temperature;
+ (void)freeModel:(nonnull void *)context;

@end
```

Create `LlamaCppBridge.mm`:

```objc
#import "LlamaCppBridge.h"
#include "llama.h"
#include <vector>
#include <string>

@implementation LlamaCppBridge

+ (void *)loadModelWithPath:(NSString *)path {
    llama_backend_init(false);

    llama_model_params model_params = llama_model_default_params();
    llama_model *model = llama_load_model_from_file([path UTF8String], model_params);

    if (!model) return NULL;

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;
    ctx_params.n_threads = 4;
    ctx_params.n_batch = 512;

    llama_context *ctx = llama_new_context_with_model(model, ctx_params);
    return ctx;
}

+ (NSString *)generateWithContext:(void *)context
                           prompt:(NSString *)prompt
                        maxTokens:(int)maxTokens
                      temperature:(float)temperature {
    // Simplified - full implementation needed
    return @"Response from llama.cpp";
}

+ (void)freeModel:(void *)context {
    if (context) {
        llama_context *ctx = (llama_context *)context;
        llama_free(ctx);
    }
    llama_backend_free();
}

@end
```

#### 4.5 Create Bridging Header

Create `MiniLLM-Bridging-Header.h`:

```objc
#ifndef MiniLLM_Bridging_Header_h
#define MiniLLM_Bridging_Header_h

#import "LlamaCppBridge.h"

#endif
```

Configure in Build Settings:
- Search: **Objective-C Bridging Header**
- Set to: `MiniLLM/MiniLLM-Bridging-Header.h`

#### 4.6 Link Libraries

1. Select project → Build Phases → Link Binary With Libraries
2. Add:
   - `libllama.a` (from build-ios/src)
   - `Metal.framework`
   - `Accelerate.framework`

---

## Step 5: Test Build

### 5.1 Build for Simulator

1. Select **iPhone 15 Pro** simulator
2. Press **⌘B** to build
3. Fix any errors (likely path issues)

### 5.2 Build for Device

1. Connect your iPhone
2. Select your iPhone as target
3. Press **⌘B**
4. May need to trust developer certificate on device

---

## Step 6: Run the App

### 6.1 Launch

Press **⌘R** to build and run

### 6.2 First Launch

The app will show:
- **Models tab**: List of available models (none downloaded)
- **Chat tab**: Empty (no model loaded)
- **Training tab**: Empty datasets
- **Server tab**: Offline
- **Settings tab**: App info

### 6.3 Download Your First Model

1. Go to **Models** tab
2. Find **TinyLlama 1.1B** (smallest, fastest to download)
3. Tap **Download**
4. Wait ~5 minutes (depends on connection)
5. Once downloaded, tap **Load**

### 6.4 Try Chatting

1. Go to **Chat** tab
2. Type: "Hello! Introduce yourself."
3. Tap send

**Note:** If using simulated inference (no llama.cpp), you'll see placeholder responses.

---

## Step 7: Enable Real Inference

To get actual AI responses, you need working llama.cpp integration:

### 7.1 Verify llama.cpp Bridge

Update `InferenceService.swift` to use real bridge:

```swift
func loadModel(path: String) async throws {
    guard let context = LlamaCppBridge.loadModel(withPath: path) else {
        throw ModelError.loadFailed
    }
    modelContext = context
    isLoaded = true
}

func generate(prompt: String, temperature: Double, maxTokens: Int) async -> String {
    guard let context = modelContext else { return "No model loaded" }

    return LlamaCppBridge.generate(
        with: context,
        prompt: prompt,
        maxTokens: Int32(maxTokens),
        temperature: Float(temperature)
    )
}
```

### 7.2 Test Real Inference

1. Download TinyLlama
2. Load it
3. Chat and verify you get real AI responses

---

## Troubleshooting

### Build Errors

**"Cannot find 'LlamaCppBridge' in scope"**
- Check bridging header path
- Ensure `.mm` file is in target

**"Undefined symbols for architecture arm64"**
- Verify `libllama.a` is linked
- Check library was built for correct architecture

**"No such module 'Metal'"**
- Add `Metal.framework` in Link Binary With Libraries

### Runtime Errors

**"Model failed to load"**
- Check file path is correct
- Ensure GGUF file is valid
- Check file permissions

**"Crash on model load"**
- May be out of memory
- Try smaller model (TinyLlama 1.1B)
- Check device has enough free RAM

**"Server won't start"**
- Check port 8080 isn't in use
- Verify network permissions in Info.plist
- Ensure model is loaded first

### Performance Issues

**Slow generation (>10 sec/token)**
- Enable Metal acceleration (`LLAMA_METAL=ON`)
- Reduce context length
- Lower thread count if overheating
- Use more aggressive quantization (Q4_0 instead of Q4_K_M)

---

## Next Steps

Once your app is running:

1. **Try Different Models**: Download Phi-2 or Gemma
2. **Create Training Dataset**: Train a LoRA adapter
3. **Start API Server**: Access from your computer
4. **Optimize Performance**: Tune thread count and batch size
5. **Customize UI**: Modify views to match your preferences

---

## Resources

- **llama.cpp Docs**: https://github.com/ggerganov/llama.cpp
- **GGUF Models**: https://huggingface.co/models?library=gguf
- **LoRA Paper**: https://arxiv.org/abs/2106.09685
- **Swift Concurrency**: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html

---

## Getting Help

If stuck:

1. Check [GitHub Issues](https://github.com/yourusername/MiniLLM-iOS/issues)
2. Read llama.cpp documentation
3. Ask in [Discussions](https://github.com/yourusername/MiniLLM-iOS/discussions)

Happy coding! 🚀
