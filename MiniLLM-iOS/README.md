# MiniLLM - On-Device AI for iPhone

<div align="center">

**Download, Train, and Host Mini Open-Source LLMs on Your iPhone**

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

---

## 🌟 Features

### 📦 Model Management
- **Download Popular Mini Models**: Pre-configured access to optimized models:
  - TinyLlama 1.1B (637 MB)
  - Phi-2 2.7B (1.6 GB)
  - Gemma 2B (1.4 GB)
  - Llama 3.2 1B (800 MB)
  - Qwen 1.8B (1.1 GB)
- **Smart Storage**: Efficient GGUF quantized models (Q4_K_M format)
- **Progress Tracking**: Real-time download progress and storage management

### 💬 Chat Interface
- **Interactive Conversations**: Natural chat UI with your loaded model
- **Customizable Generation**: Adjust temperature, max tokens, and other parameters
- **Message History**: Keep track of conversations
- **Streaming Support**: Token-by-token response generation (simulated)

### 🧠 On-Device Training
- **LoRA Fine-Tuning**: Train lightweight adapters without modifying base model
- **Custom Datasets**: Create training datasets from conversations or manual input
- **Progress Monitoring**: Real-time training progress and loss tracking
- **Efficient Training**: Low-rank adaptation minimizes memory usage

### 🌐 Local API Server
- **OpenAI-Compatible API**: Drop-in replacement for OpenAI API
- **Network Accessible**: Access your model from any device on your network
- **Endpoints**:
  - `POST /v1/chat/completions` - Chat completions
  - `GET /v1/models` - List models
  - `GET /health` - Health check
- **Request Monitoring**: Track API usage and performance

---

## 📋 Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **iPhone 12 or newer** (for optimal performance)
- **At least 4GB free storage** (for models)

---

## 🚀 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/MiniLLM-iOS.git
cd MiniLLM-iOS
```

### Step 2: Install llama.cpp

The core inference engine requires llama.cpp. You'll need to integrate it:

#### Option A: Swift Package (Recommended)

Add to your Xcode project:
1. File → Add Package Dependencies
2. Search for `llama.cpp` Swift bindings
3. Add to your target

#### Option B: Manual Integration

```bash
# Clone llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Build for iOS
mkdir build-ios && cd build-ios
cmake .. -DCMAKE_SYSTEM_NAME=iOS \
         -DCMAKE_OSX_ARCHITECTURES=arm64 \
         -DLLAMA_METAL=ON

make -j
```

Then add the built library to your Xcode project.

### Step 3: Create Bridging Header

Create `MiniLLM-Bridging-Header.h`:

```objc
#ifndef MiniLLM_Bridging_Header_h
#define MiniLLM_Bridging_Header_h

// Include llama.cpp headers
#import "llama.h"

#endif
```

### Step 4: Build and Run

1. Open `MiniLLM.xcodeproj` in Xcode
2. Select your iPhone as the target device
3. Build and run (⌘R)

---

## 📱 Usage

### Download a Model

1. Open the **Models** tab
2. Browse available models
3. Tap **Download** on your preferred model
4. Wait for download to complete
5. Tap **Load** to load into memory

### Chat with Your Model

1. Go to the **Chat** tab
2. Ensure a model is loaded (green indicator)
3. Type your message and tap send
4. Adjust settings (temperature, max tokens) via settings icon

### Train a LoRA Adapter

1. Navigate to **Training** tab
2. Tap **+** to create new dataset
3. Add training examples (min 10 recommended):
   - Input: The prompt
   - Output: Expected response
4. Save dataset
5. Select dataset and tap **Train LoRA Adapter**
6. Monitor training progress

### Run API Server

1. Go to **Server** tab
2. Ensure model is loaded
3. Tap **Start Server**
4. Note the server URL (e.g., `http://192.168.1.100:8080`)
5. Make requests from any device on your network:

```bash
curl http://YOUR_IPHONE_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello! How are you?"}
    ],
    "temperature": 0.7,
    "max_tokens": 512
  }'
```

---

## 🏗️ Architecture

### Project Structure

```
MiniLLM-iOS/
├── MiniLLM-iOS/
│   ├── MiniLLMApp.swift          # App entry point
│   ├── ContentView.swift          # Main tab view
│   │
│   ├── Models/                    # Data models
│   │   └── LLMModel.swift         # Model definitions
│   │
│   ├── ViewModels/                # State management
│   │   ├── ModelManager.swift     # Model lifecycle
│   │   └── ServerManager.swift    # Server control
│   │
│   ├── Views/                     # SwiftUI views
│   │   ├── ModelsView.swift       # Model management
│   │   ├── ChatView.swift         # Chat interface
│   │   ├── TrainingView.swift     # Training UI
│   │   ├── ServerView.swift       # Server dashboard
│   │   └── SettingsView.swift     # App settings
│   │
│   └── Services/                  # Business logic
│       ├── ModelDownloadService.swift   # Download handling
│       ├── InferenceService.swift       # llama.cpp interface
│       ├── TrainingService.swift        # LoRA training
│       └── ServerService.swift          # HTTP server
│
├── Info.plist                     # App configuration
├── Package.swift                  # Dependencies
└── README.md                      # This file
```

### Technology Stack

- **UI Framework**: SwiftUI
- **Inference Engine**: llama.cpp (C++ with Swift bridge)
- **Networking**: Network.framework (native HTTP server)
- **ML Framework**: Metal Performance Shaders (GPU acceleration)
- **Storage**: FileManager + UserDefaults
- **Concurrency**: Swift Concurrency (async/await, actors)

### Key Components

#### 1. InferenceService (Actor)
- Bridges Swift ↔️ llama.cpp (C++)
- Handles model loading/unloading
- Token generation and sampling
- Thread-safe model access

#### 2. TrainingService (Actor)
- Implements LoRA (Low-Rank Adaptation)
- Backpropagation for fine-tuning
- Adapter weight management
- Dataset preparation

#### 3. ServerService (Actor)
- HTTP server using Network.framework
- OpenAI API compatibility
- Request/response handling
- CORS support

---

## 🔧 Implementation Details

### llama.cpp Integration

The app requires a C++ ↔️ Swift bridge. Here's how to implement it:

#### Create `LlamaCppBridge.h` (Objective-C++):

```objc
#import <Foundation/Foundation.h>

@interface LlamaCppBridge : NSObject

+ (void *)loadModelWithPath:(NSString *)path;
+ (NSString *)generateWithContext:(void *)context
                           prompt:(NSString *)prompt
                        maxTokens:(int)maxTokens
                      temperature:(float)temperature;
+ (void)freeModel:(void *)context;

@end
```

#### Create `LlamaCppBridge.mm`:

```objc
#import "LlamaCppBridge.h"
#include "llama.h"
#include <string>

@implementation LlamaCppBridge

+ (void *)loadModelWithPath:(NSString *)path {
    llama_model_params model_params = llama_model_default_params();
    llama_model *model = llama_load_model_from_file([path UTF8String], model_params);

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;
    ctx_params.n_threads = 4;

    llama_context *ctx = llama_new_context_with_model(model, ctx_params);
    return ctx;
}

+ (NSString *)generateWithContext:(void *)context
                           prompt:(NSString *)prompt
                        maxTokens:(int)maxTokens
                      temperature:(float)temperature {
    llama_context *ctx = (llama_context *)context;

    // Tokenization
    std::string prompt_str = [prompt UTF8String];
    std::vector<llama_token> tokens = llama_tokenize(ctx, prompt_str, true);

    // Inference loop
    std::string result;
    for (int i = 0; i < maxTokens; i++) {
        llama_eval(ctx, tokens.data(), tokens.size(), i, 4);

        llama_token new_token = llama_sample_token(ctx, NULL);
        if (new_token == llama_token_eos(ctx)) break;

        result += llama_token_to_str(ctx, new_token);
        tokens.push_back(new_token);
    }

    return [NSString stringWithUTF8String:result.c_str()];
}

+ (void)freeModel:(void *)context {
    llama_context *ctx = (llama_context *)context;
    llama_free(ctx);
}

@end
```

#### Update `InferenceService.swift`:

```swift
actor InferenceService {
    private var modelContext: UnsafeMutableRawPointer?

    func loadModel(path: String) async throws {
        modelContext = LlamaCppBridge.loadModel(withPath: path)
        if modelContext == nil {
            throw ModelError.loadFailed
        }
    }

    func generate(prompt: String, temperature: Double, maxTokens: Int) async -> String {
        guard let context = modelContext else { return "" }
        return LlamaCppBridge.generate(
            with: context,
            prompt: prompt,
            maxTokens: Int32(maxTokens),
            temperature: Float(temperature)
        )
    }

    func unloadModel() {
        if let context = modelContext {
            LlamaCppBridge.freeModel(context)
        }
        modelContext = nil
    }
}
```

### Metal Acceleration

For GPU-accelerated inference, enable Metal in llama.cpp:

```swift
// In model loading parameters
model_params.use_metal = true
ctx_params.n_gpu_layers = 99 // Offload layers to GPU
```

---

## 🎯 Performance Tips

### Model Selection
- **iPhone 12-13**: TinyLlama (1.1B) or Llama 3.2 1B
- **iPhone 14**: Phi-2 (2.7B) or Gemma 2B
- **iPhone 15 Pro**: Any model up to 3B parameters

### Optimization
- **Use Q4_K_M quantization** for best size/quality ratio
- **Enable Metal** for 3-5x faster inference
- **Limit context length** to save memory
- **Batch processing** for multiple requests
- **LoRA adapters** instead of full fine-tuning

### Battery Life
- Lower thread count (2-4 threads)
- Reduce max tokens per generation
- Unload model when not in use

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

---

## 🙏 Acknowledgments

- **llama.cpp** - Inference engine by Georgi Gerganov
- **Hugging Face** - Model hosting and community
- **Apple** - Metal and iOS frameworks
- **LoRA** - Low-Rank Adaptation research (Hu et al., 2021)

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/MiniLLM-iOS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/MiniLLM-iOS/discussions)

---

<div align="center">

**Built with ❤️ for the open-source AI community**

</div>
