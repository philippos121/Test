# 🚀 MiniLLM iOS - Complete Installation Guide
## Run Real AI Locally on Your iPhone!

---

## 🎯 What You're Getting

A **fully functional iOS app** that runs **real AI models locally** on your iPhone using **llama.cpp**:

- ✅ **Real LLM inference** - Not simulated, actual AI!
- ✅ **Metal acceleration** - Uses iPhone GPU for speed
- ✅ **100% offline** - No internet needed after model download
- ✅ **Multiple models** - TinyLlama, Phi-2, Gemma, Mistral, more
- ✅ **Chat interface** - iMessage-style conversations
- ✅ **API server** - OpenAI-compatible endpoints
- ✅ **Training** - Fine-tune models with LoRA
- ✅ **Complete privacy** - Everything runs on your device

---

## 📱 Installation (Choose Your Path)

### **Option 1: Cloud Build + AltStore** (Easiest - No Mac!)

**Time: 10 minutes**

#### Step 1: Trigger GitHub Build

```bash
# Push to trigger workflow
git push origin claude/your-branch
```

Or manually:
1. Go to GitHub repo → Actions tab
2. Click "Build iOS App with llama.cpp"
3. Click "Run workflow"
4. Wait 15-20 minutes for build

#### Step 2: Download IPA

1. Go to Actions tab → Latest successful workflow
2. Download `MiniLLM-iOS-Release` artifact
3. Unzip the file
4. You'll find `MiniLLM.ipa`

#### Step 3: Install with AltStore

1. **Install AltStore** on iPhone:
   - Visit https://altstore.io
   - Follow their guide for your platform:
     - **Mac**: Install AltServer, pair iPhone
     - **Windows**: Same process
   - Install AltStore app on iPhone via Settings

2. **Sign and Install IPA**:
   - Open AltStore on iPhone
   - Tap "+" in top-left
   - Browse and select `MiniLLM.ipa`
   - Enter your Apple ID (stay signed in)
   - Wait for signing process
   - App installs automatically!

3. **Trust Developer**:
   - Go to: Settings → General → VPN & Device Management
   - Find your Apple ID
   - Tap "Trust"

4. **Launch MiniLLM!** 🎉

---

### **Option 2: Build with Xcode** (Mac required)

**Time: 30 minutes**

#### Prerequisites

- Mac with Xcode 15+
- iPhone with iOS 16+
- Apple Developer account (free works!)

#### Steps

```bash
# 1. Clone repo
git clone <your-repo>
cd MiniLLM-iOS

# 2. Generate Xcode project
chmod +x create_xcode_project_full.sh
./create_xcode_project_full.sh

# 3. Clone and build llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Build for iOS device
mkdir build-ios && cd build-ios
cmake .. \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DLLAMA_METAL=ON \
  -DBUILD_SHARED_LIBS=OFF
make -j8
cd ../..

# 4. Link to project
mkdir -p Frameworks
cp llama.cpp/build-ios/src/libllama.a Frameworks/

# 5. Open in Xcode
open MiniLLM.xcodeproj

# 6. In Xcode:
#    - Connect iPhone
#    - Select iPhone as target
#    - Press ⌘R to build and run
```

---

### **Option 3: TrollStore** (Permanent install - no 7-day limit)

If you have TrollStore installed:

1. Download `MiniLLM.ipa` from GitHub Actions
2. Open in TrollStore
3. Tap "Install"
4. Done! No re-signing needed

---

## 🎮 First Time Setup

### Download Your First Model

1. **Open MiniLLM** app
2. Tap **Models** tab
3. See list of available models:
   - **TinyLlama 1.1B** ← Start here! (600MB)
   - Phi-2 2.7B (1.6GB)
   - Gemma 2B (1.4GB)
   - Mistral 7B (4.1GB)
   - Llama 3.2 1B (1.3GB)

4. **Tap TinyLlama** → **Download**
5. Wait for download (5-10 min on WiFi)
6. **Tap "Load Model"** when done
7. See ✅ green checkmark = Ready!

### Start Chatting

1. Go to **Chat** tab
2. Type: "Hello! Tell me about yourself."
3. Tap Send
4. Watch real AI response! 🤖

**First response might be slow (10-15 seconds) while model loads into RAM.**

---

## 💡 Usage Guide

### Chat Interface

- **Type messages** like any chat app
- **Swipe to delete** messages
- **Clear conversation** button
- **Adjust temperature** for creativity
- **Set max tokens** for response length

### Models Tab

- **Download** multiple models
- **Switch** between models anytime
- **Delete** to free space
- **View** model info and size

### Training Tab

- **Create datasets** for fine-tuning
- **Add Q&A pairs** (question → answer)
- **Train LoRA** adapters (small fine-tune files)
- **Load adapters** with base model

### Server Tab

- **Start API server** on your iPhone
- **OpenAI-compatible** endpoints
- Access from computer on same WiFi:
  ```bash
  curl http://YOUR_IPHONE_IP:8080/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tinyllama",
      "messages": [{"role": "user", "content": "Hello!"}]
    }'
  ```

### Settings Tab

- **View storage** usage
- **Clear cache**
- **Adjust performance**
- **Check app version**

---

## 🔧 Advanced Features

### Custom Models

1. Download any GGUF model from HuggingFace
2. Use iTunes File Sharing or similar to copy to app
3. Models appear in Models tab
4. Load and use!

**Recommended sources:**
- https://huggingface.co/models?library=gguf
- https://huggingface.co/TheBloke

### Metal Acceleration

**Automatically enabled!** Uses iPhone's GPU for 5-10x faster inference.

Check Settings tab to see Metal status.

### Memory Management

**iPhone RAM Limits:**
- iPhone 12/13: 4-6GB → Up to 3B models
- iPhone 14: 6GB → Up to 7B models (Q4)
- iPhone 15 Pro: 8GB → Up to 7B models (Q5)

**If app crashes:**
- Use smaller models
- Try more aggressive quantization (Q4_0 instead of Q5)
- Close background apps
- Restart iPhone

---

## ❓ Troubleshooting

### Installation Issues

**"Untrusted Developer"**
- Settings → General → VPN & Device Management
- Trust your Apple ID certificate

**"Unable to Verify App"**
- Disable WiFi temporarily
- Open app
- Re-enable WiFi

**"This app cannot be installed"**
- Delete old version first
- Re-sign with AltStore
- Check storage space

### Runtime Issues

**"Model failed to load"**
- Model might be corrupted → Re-download
- Not enough RAM → Try smaller model
- Check model is .gguf format

**"Generation takes forever"**
- First inference is slow (model loading)
- Reduce max tokens
- Try lower quantization
- Ensure Metal is enabled

**"App crashes on model load"**
- Model too large for device
- Close background apps
- Restart iPhone
- Try TinyLlama 1.1B first

**"Can't download models"**
- Check internet connection
- Check storage space (need 2x model size)
- Try smaller model first

### Performance Issues

**Slow inference (>5 sec/token)**
- Check Metal is enabled (Settings tab)
- Reduce context window
- Use Q4_0 quantization
- Close background apps

**App gets hot**
- Normal for AI inference
- Take breaks between long generations
- Reduce thread count in Settings
- Use lower quantization

---

## 📊 Model Comparison

| Model | Size | RAM | Speed | Quality | Best For |
|-------|------|-----|-------|---------|----------|
| **TinyLlama 1.1B** | 600MB | 2GB | ⚡⚡⚡ | ⭐⭐ | Testing, learning |
| **Llama 3.2 1B** | 1.3GB | 2.5GB | ⚡⚡⚡ | ⭐⭐⭐ | General use |
| **Phi-2 2.7B** | 1.6GB | 3.5GB | ⚡⚡ | ⭐⭐⭐⭐ | Smart responses |
| **Gemma 2B** | 1.4GB | 3GB | ⚡⚡ | ⭐⭐⭐⭐ | Conversations |
| **Mistral 7B Q4** | 4.1GB | 6GB | ⚡ | ⭐⭐⭐⭐⭐ | Best quality |

**Recommendation:** Start with **TinyLlama** to test, then upgrade to **Phi-2** or **Gemma** for daily use.

---

## 🎓 How It Works

### Architecture

```
┌─────────────────────────────────────┐
│  SwiftUI Interface                  │
│  (Chat, Models, Training, Server)   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Swift Services Layer               │
│  • InferenceService                 │
│  • ModelManager                     │
│  • ServerService                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Objective-C++ Bridge               │
│  (LlamaCppBridge.mm)                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  llama.cpp (C++)                    │
│  • Tokenization                     │
│  • Inference Loop                   │
│  • Metal Backend (GPU)              │
│  • Sampling                         │
└─────────────────────────────────────┘
```

### Inference Flow

1. **User types message** in Chat UI
2. **InferenceService** receives prompt
3. **LlamaCppBridge** tokenizes text
4. **llama.cpp** runs inference:
   - Processes prompt tokens
   - Generates new tokens iteratively
   - Uses Metal GPU acceleration
   - Applies temperature sampling
5. **Tokens decoded** to text
6. **Text streamed** back to UI
7. **User sees response** word-by-word!

### Metal Acceleration

**How it works:**
- llama.cpp compiles Metal shaders
- Matrix operations offloaded to GPU
- 5-10x faster than CPU-only
- Lower battery usage
- Cooler device temperature

**Automatically used for:**
- Model attention layers
- Matrix multiplications
- Activations (GELU, SiLU, etc.)

---

## 🔒 Privacy & Security

### What Stays Private

✅ **Everything!**
- All inference happens on your iPhone
- No data sent to cloud
- No analytics collected
- No internet needed (after download)
- Models stored locally
- Conversations never uploaded

### Data Storage

- **Models**: `Documents/models/`
- **Conversations**: In-memory only (not saved)
- **Training datasets**: `Documents/datasets/`
- **LoRA adapters**: `Documents/loras/`

### Permissions Needed

- **Network** - Only for model downloads and API server
- **Storage** - To save models and datasets

**No permissions for:**
- Camera, Microphone, Location, Contacts, Photos

---

## 🆘 Getting Help

### Documentation

- **SETUP_GUIDE.md** - Technical setup details
- **README.md** - Full API documentation
- **QUICK_START.md** - Feature overview

### Community

- GitHub Issues: Report bugs
- GitHub Discussions: Ask questions
- llama.cpp Docs: https://github.com/ggerganov/llama.cpp

### Debug Logs

Enable in Settings tab → "Debug Mode" → See console logs

---

## 🎉 You're Ready!

Now you have a **fully functional AI assistant running locally on your iPhone!**

**Next steps:**
1. Download TinyLlama
2. Chat and test
3. Try other models
4. Explore training
5. Start API server

**Enjoy your private, offline AI! 🚀**

---

## 📝 Quick Reference

### Essential Commands

```bash
# Trigger cloud build
git push origin your-branch

# Generate Xcode project
./create_xcode_project_full.sh

# Build llama.cpp for iOS
cmake .. -DCMAKE_SYSTEM_NAME=iOS -DLLAMA_METAL=ON
make -j8
```

### File Locations

- **Models**: `Documents/models/*.gguf`
- **Project**: `MiniLLM.xcodeproj`
- **llama.cpp**: `llama.cpp/build-ios/src/libllama.a`

### Key Specs

- **Min iOS**: 16.0
- **Min iPhone**: iPhone 11 or newer
- **Recommended**: iPhone 13 Pro or newer with 6GB+ RAM

---

**Built with ❤️ by the open-source community**

**Powered by llama.cpp**
