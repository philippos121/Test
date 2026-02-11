# Quick Start Guide - MiniLLM iOS

Get up and running in 10 minutes with simulated inference (no llama.cpp required for testing UI).

## Fast Track Setup (UI Testing Only)

### 1. Open in Xcode (2 minutes)

```bash
cd MiniLLM-iOS
open -a Xcode MiniLLM-iOS.xcodeproj
```

If you don't have an `.xcodeproj` file yet:

1. Open Xcode
2. File → New → Project
3. iOS → App
4. Name: `MiniLLM`, Interface: SwiftUI, Language: Swift

### 2. Copy Files (3 minutes)

Drag and drop these folders into your Xcode project:

- `Models/` → Create group "Models"
- `Views/` → Create group "Views"
- `ViewModels/` → Create group "ViewModels"
- `Services/` → Create group "Services"

Copy these root files:
- `MiniLLMApp.swift` → Replace default
- `ContentView.swift` → Replace default
- `Info.plist` → Merge with existing

### 3. Configure (1 minute)

1. Select project in navigator
2. Set **Deployment Target**: iOS 16.0
3. Select **Signing & Capabilities** → Choose your team

### 4. Build & Run (2 minutes)

1. Select iPhone 15 Pro simulator
2. Press ⌘R
3. Wait for build and launch

### 5. Test the UI (2 minutes)

**Models Tab:**
- See list of 5 mini LLMs
- Tap "Download" on TinyLlama (simulated, instant)
- Tap "Load" to load model

**Chat Tab:**
- Type "Hello!" and send
- Get simulated response (placeholder text)

**Training Tab:**
- Create new dataset
- Add 5 example pairs
- Start training (simulated progress)

**Server Tab:**
- Start server
- See simulated API endpoints
- Copy curl command

**Settings Tab:**
- Check storage usage
- View app info

---

## Add Real AI (Optional - Requires llama.cpp)

To get actual AI responses instead of simulated ones, you need llama.cpp integration.

### Option 1: Use Pre-built Package (Easiest)

When available, add via SPM:

```
File → Add Package Dependencies
URL: https://github.com/ggerganov/llama.cpp
```

### Option 2: Build Yourself (Advanced)

See [SETUP_GUIDE.md](SETUP_GUIDE.md) Step 4 for full instructions.

**Quick version:**

```bash
# Clone llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Build for iOS
mkdir build-ios && cd build-ios
cmake .. -DCMAKE_SYSTEM_NAME=iOS -DLLAMA_METAL=ON
make -j8

# Add libllama.a to Xcode project
# Create Objective-C++ bridge (see SETUP_GUIDE.md)
```

---

## Real Model Download

Once llama.cpp is integrated:

### Download GGUF Model

```bash
# Download TinyLlama (1.1B, ~637MB)
curl -L -o ~/Downloads/tinyllama.gguf \
  https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
```

### Load in App

1. Use AirDrop or iTunes File Sharing to transfer to iPhone
2. Or modify `ModelDownloadService` to download directly
3. Load model in app
4. Chat with real AI!

---

## Simulated vs Real Comparison

| Feature | Simulated (Default) | Real (with llama.cpp) |
|---------|---------------------|----------------------|
| Download | Instant, fake | ~5-10 min real download |
| Model Load | Instant | 3-10 seconds |
| Inference | Placeholder text | Real AI responses |
| Training | Progress bar only | Actual LoRA training |
| Server | Endpoints work, fake responses | Real OpenAI-compatible API |

---

## File Structure Overview

```
MiniLLM-iOS/
├── MiniLLMApp.swift              # 🚀 App entry point
├── ContentView.swift              # 📱 Main tab view
│
├── Models/
│   └── LLMModel.swift             # 📦 Data structures
│
├── ViewModels/
│   ├── ModelManager.swift         # 🧠 Model lifecycle manager
│   └── ServerManager.swift        # 🌐 Server state manager
│
├── Views/
│   ├── ModelsView.swift           # 📚 Model download/management UI
│   ├── ChatView.swift             # 💬 Chat interface
│   ├── TrainingView.swift         # 🎓 Training dataset UI
│   ├── ServerView.swift           # 🖥️ API server dashboard
│   └── SettingsView.swift         # ⚙️ App settings
│
└── Services/
    ├── ModelDownloadService.swift # ⬇️ Download manager
    ├── InferenceService.swift     # 🤖 llama.cpp interface
    ├── TrainingService.swift      # 📊 LoRA training engine
    └── ServerService.swift        # 🔌 HTTP server
```

---

## Common Questions

**Q: Why are responses fake?**
A: You need llama.cpp integration. The default uses simulated inference to test UI without the complexity of C++ integration.

**Q: Can I test on physical iPhone?**
A: Yes! Just select your iPhone as target. You'll need to trust the developer certificate on device.

**Q: What's the smallest model I can use?**
A: TinyLlama 1.1B (~637MB) is the smallest and works great on iPhone 12+.

**Q: Will this drain my battery?**
A: AI inference is compute-intensive. Expect 15-30 min of continuous generation on a full charge. Enable battery optimization in settings.

**Q: Can I use this offline?**
A: Yes! Once models are downloaded, everything runs 100% offline and on-device.

**Q: Is my data sent anywhere?**
A: No. All processing is on-device. No data leaves your iPhone unless you explicitly use the API server feature.

---

## Next Steps

1. **Explore the UI** - Click around, test all features
2. **Read Architecture** - Understand how components work ([README.md](README.md))
3. **Integrate llama.cpp** - Get real AI ([SETUP_GUIDE.md](SETUP_GUIDE.md))
4. **Customize** - Modify views, add features
5. **Deploy** - TestFlight or App Store (with proper model licenses)

---

## Pro Tips

### Performance
- Use Q4_K_M quantization (best balance)
- Enable Metal acceleration (3-5x faster)
- Limit context to 2048 tokens
- Use 4 threads on modern iPhones

### Storage
- Delete unused models (each is 0.5-2GB)
- Use LoRA adapters instead of full fine-tuning
- Clear chat history regularly

### Development
- Test on simulator first (faster iteration)
- Use Instruments to profile (Xcode → Product → Profile)
- Enable console logging for debugging
- Test on oldest supported device (iPhone 12)

---

## Troubleshooting

**Build Error: "Cannot find module 'xyz'"**
→ Check all files are added to target (File Inspector → Target Membership)

**Simulator Crash on Launch**
→ Clean build folder (⌘⇧K), rebuild

**"No active model" in chat**
→ Load a model in Models tab first

**App uses too much memory**
→ Use smaller model, reduce context length

---

## Resources

- 📚 [Full README](README.md) - Complete documentation
- 🛠️ [Setup Guide](SETUP_GUIDE.md) - Detailed setup instructions
- 🌟 [llama.cpp](https://github.com/ggerganov/llama.cpp) - Inference engine
- 🤗 [Hugging Face](https://huggingface.co/models?library=gguf) - Model downloads

---

**You're ready to go! Start exploring MiniLLM 🚀**
