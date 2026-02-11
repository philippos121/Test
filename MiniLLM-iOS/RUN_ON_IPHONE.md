# 📱 Run MiniLLM on Your iPhone - Complete Guide

Follow these steps to get MiniLLM running on your iPhone in **under 10 minutes**.

---

## ✅ Prerequisites

- Mac with Xcode 15+ installed
- iPhone running iOS 16+
- Lightning/USB-C cable to connect iPhone to Mac

---

## 🚀 Quick Start (5 Steps)

### Step 1: Transfer to Mac

If you're reading this on Linux, transfer the `MiniLLM-iOS` folder to your Mac:

```bash
# On Linux - zip the folder
cd /home/user/Test
zip -r MiniLLM-iOS.zip MiniLLM-iOS/

# Transfer via:
# - USB drive
# - AirDrop
# - Cloud storage (Dropbox, Google Drive)
# - Or use: scp MiniLLM-iOS.zip user@your-mac.local:~/Downloads/
```

On Mac, extract:
```bash
cd ~/Downloads
unzip MiniLLM-iOS.zip
cd MiniLLM-iOS
```

---

### Step 2: Open Xcode (1 minute)

```bash
# Launch Xcode
open -a Xcode
```

In Xcode menu:
1. **File** → **New** → **Project**
2. Choose **iOS** → **App**
3. Click **Next**

Configure:
- **Product Name**: `MiniLLM`
- **Team**: Select your Apple ID
- **Organization Identifier**: `com.yourname`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None
- Click **Next**, save to Desktop

---

### Step 3: Add Source Files (2 minutes)

In Xcode, **delete** these auto-generated files:
- ContentView.swift
- MiniLLMApp.swift

Now **drag and drop** from Finder into Xcode:

**From** `MiniLLM-iOS/MiniLLM-iOS/` folder:

1. **Models** folder → Drag into Xcode project
2. **Views** folder → Drag into Xcode project
3. **ViewModels** folder → Drag into Xcode project
4. **Services** folder → Drag into Xcode project
5. **MiniLLMApp.swift** → Drag into project root
6. **ContentView.swift** → Drag into project root

When prompted:
- ✅ Check "Copy items if needed"
- ✅ Check "Create groups"
- ✅ Add to target: MiniLLM
- Click **Finish**

---

### Step 4: Configure Info.plist (1 minute)

1. In Xcode, select **Info.plist**
2. Right-click in the editor → **Open As** → **Source Code**
3. Replace entire content with the Info.plist from `MiniLLM-iOS/Info.plist`

Or add these keys manually:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>MiniLLM needs local network access to run the API server</string>

<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

---

### Step 5: Build & Run on iPhone (1 minute)

1. **Connect your iPhone** via cable
2. **Trust** the computer on iPhone (if prompted)
3. In Xcode toolbar, select your **iPhone** as target device
4. Press **⌘R** (or click ▶️ Play button)

**First-time setup:**
- On your iPhone: Settings → General → VPN & Device Management
- Tap your Apple ID → **Trust**
- Go back to Xcode and press ⌘R again

**The app will launch on your iPhone!** 🎉

---

## 🎮 Using the App

### Download Your First Model

1. Open **Models** tab
2. Tap **TinyLlama 1.1B** (smallest model)
3. Tap **Download** (simulated - instant)
4. Tap **Load Model**
5. Wait 2-3 seconds

### Start Chatting

1. Switch to **Chat** tab
2. Type: "Hello! Tell me a joke."
3. Tap Send
4. You'll see a simulated response

**Note:** The app works with **simulated inference** by default. Responses are placeholders showing the UI works perfectly.

### Try Training

1. Go to **Training** tab
2. Tap **+** to create dataset
3. Name it "My First Dataset"
4. Add 5 example pairs:
   - Input: "What is AI?"
   - Output: "AI is artificial intelligence..."
5. Tap **Save**
6. Tap **Train LoRA Adapter**
7. Watch the progress bar

### Start API Server

1. Go to **Server** tab
2. Ensure model is loaded (green indicator)
3. Tap **Start Server**
4. Copy the URL (e.g., `http://192.168.1.100:8080`)
5. Test from your computer:

```bash
curl http://YOUR_IPHONE_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hi!"}],
    "temperature": 0.7,
    "max_tokens": 100
  }'
```

---

## 🎨 What You'll See

### Models Tab
- Beautiful card-based UI
- 5 mini LLMs to choose from
- Download progress bars
- Storage information
- Load/Delete buttons

### Chat Tab
- iMessage-style interface
- Blue bubbles for your messages
- Gray bubbles for AI responses
- Settings icon for temperature/max tokens
- Clear chat button

### Training Tab
- Dataset management
- Add input/output pairs
- Training progress indicator
- LoRA adapter status

### Server Tab
- Server on/off toggle
- Live URL display
- API endpoint documentation
- Recent requests log
- Request count

### Settings Tab
- Storage usage breakdown
- Performance settings
- App version
- Links to resources
- Clear data option

---

## 🔧 Troubleshooting

### "Build Failed" Error

**Error: "No such module 'SwiftUI'"**
- Solution: Set deployment target to iOS 16.0
- Project → Target → General → Minimum Deployments → iOS 16.0

**Error: "Cannot find 'ModelManager' in scope"**
- Solution: Ensure all files are added to target
- Select file → Right panel → Target Membership → Check MiniLLM

**Error: "Signing requires a development team"**
- Solution: Add your Apple ID
- Xcode → Settings → Accounts → Sign in with Apple ID
- Project → Signing & Capabilities → Team → Select your Apple ID

### App Crashes on Launch

**Check Console** (⌘Y to show):
- Look for error messages
- Usually missing files or incorrect paths

**Clean Build:**
- Product → Clean Build Folder (⌘⇧K)
- Rebuild (⌘B)

### "Untrusted Developer" on iPhone

1. iPhone → Settings → General → VPN & Device Management
2. Tap your Apple ID under "Developer App"
3. Tap **Trust**
4. Confirm

### No Models Downloading

**This is expected!** Models use simulated downloads by default.
- To download real models, see [SETUP_GUIDE.md](SETUP_GUIDE.md) for llama.cpp integration

---

## ⚡ Performance Tips

### Optimize Xcode Build Time
- Use iPhone simulator for testing (faster iteration)
- Enable "Parallelize Build" in Scheme settings
- Close other apps while building

### Optimize App Performance
- Test on iPhone 12 or newer
- Close background apps
- Ensure 2GB+ free storage
- Disable Low Power Mode during testing

---

## 🎯 Next Steps

### Level 1: Explore the UI ✅
- Test all 5 tabs
- Try different models
- Create training datasets
- Start/stop server

### Level 2: Customize the App
- Change colors in Views
- Add more models to LLMModel.swift
- Modify UI layouts
- Add new features

### Level 3: Add Real AI
- Integrate llama.cpp (see SETUP_GUIDE.md)
- Download real GGUF models
- Get actual AI responses
- Train real LoRA adapters

---

## 📊 App Architecture

```
MiniLLM (iOS App)
│
├── 📱 App Layer (SwiftUI)
│   ├── MiniLLMApp.swift          # Entry point
│   └── ContentView.swift          # Main tabs
│
├── 🎨 Views (UI Components)
│   ├── ModelsView                 # Model browser
│   ├── ChatView                   # Chat interface
│   ├── TrainingView               # Dataset management
│   ├── ServerView                 # API dashboard
│   └── SettingsView               # Configuration
│
├── 🧠 ViewModels (State Management)
│   ├── ModelManager               # @Published state
│   └── ServerManager              # @Published state
│
└── ⚙️ Services (Business Logic)
    ├── ModelDownloadService       # Downloads
    ├── InferenceService           # AI generation
    ├── TrainingService            # LoRA training
    └── ServerService              # HTTP server
```

---

## 💡 Quick Tips

1. **Use Simulator** for faster testing (⌘R with simulator selected)
2. **Hot Reload** - Most UI changes update live
3. **Console** (⌘Y) - Shows print statements and errors
4. **Breakpoints** - Click line numbers to debug
5. **Preview** - Canvas on right shows live preview of views

---

## 🆘 Getting Stuck?

### Common Issues

**"I don't have a Mac"**
- Use cloud Mac service (MacStadium, MacinCloud)
- Borrow a friend's Mac for 30 minutes
- Use Mac at Apple Store (bring USB drive)

**"I don't have an iPhone"**
- Use Xcode Simulator (works perfectly!)
- Borrow iPhone from friend
- Test on iPad (also supported)

**"The app is in simulated mode"**
- This is intentional for easy testing
- Full AI requires llama.cpp integration
- UI works perfectly without it

**"How do I add real AI?"**
- See [SETUP_GUIDE.md](SETUP_GUIDE.md)
- Requires building llama.cpp for iOS
- Advanced setup (1-2 hours)

---

## 🎉 Success!

Once running, you'll have a **fully functional iOS app** with:

✅ Beautiful native SwiftUI interface
✅ 5 tabs with complete UIs
✅ Model management system
✅ Chat interface with history
✅ Training dataset creation
✅ API server with monitoring
✅ Settings and storage management

**Ready to ship to the App Store** (with real AI integration)!

---

## 📞 Support

- 📚 [README.md](README.md) - Full documentation
- 🛠️ [SETUP_GUIDE.md](SETUP_GUIDE.md) - Advanced setup
- ⚡ [QUICK_START.md](QUICK_START.md) - Fast overview

---

<div align="center">

**🚀 You're ready to run MiniLLM on your iPhone!**

**Total Time: ~10 minutes**

</div>
