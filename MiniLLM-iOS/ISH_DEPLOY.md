# 📱 Deploy MiniLLM on iPhone using iSH

Deploy MiniLLM **directly from your iPhone** using iSH - **no Mac required!**

---

## ⚡ Ultra-Quick Start (iSH)

**On your iPhone in iSH:**

```bash
cd /root
git clone https://github.com/YOUR_USERNAME/Test
cd Test/MiniLLM-iOS
chmod +x deploy_ish.sh
./deploy_ish.sh
```

Choose option **1** (Cloud Build) and follow the prompts!

**Total time: 5 minutes** (including cloud build)

---

## 📋 What is iSH?

**iSH** is a Linux shell environment for iOS:
- Runs Alpine Linux on iPhone/iPad
- Full terminal access
- Package manager (apk)
- Git, curl, and other tools
- **Perfect for development on iOS!**

### Install iSH

1. Open **App Store** on iPhone
2. Search **"iSH Shell"**
3. Install (free!)
4. Open iSH

---

## 🚀 Three Deployment Methods

### Method 1: Cloud Build (Recommended) ⭐

**Build in the cloud, install on iPhone**

```
iSH → GitHub → GitHub Actions → IPA → AltStore → iPhone
```

**Pros:**
- ✅ No Mac needed
- ✅ Fully automated
- ✅ Free (GitHub Actions)
- ✅ Professional build

**Time:** 5-10 minutes

---

### Method 2: Export for Mac

**Prepare in iSH, build on Mac**

```
iSH → Export ZIP → Transfer → Mac → Xcode → iPhone
```

**Pros:**
- ✅ Full Xcode features
- ✅ Local debugging
- ✅ Complete control

**Time:** 15 minutes

---

### Method 3: Pythonista Bridge (Experimental)

**Use Pythonista for local build**

```
iSH → Pythonista → Build → Install
```

**Pros:**
- ✅ No cloud needed
- ✅ No Mac needed
- ✅ Advanced experimentation

**Cons:**
- ⚠️ Requires Pythonista ($10)
- ⚠️ Experimental
- ⚠️ Advanced users only

**Time:** 30 minutes

---

## 📦 Method 1: Cloud Build (Detailed)

### Step 1: Install iSH and Tools

**In iSH:**

```bash
# Update package manager
apk update

# Install required tools
apk add git curl zip unzip jq

# Verify installation
git --version
curl --version
```

### Step 2: Clone or Create Project

**Option A: Clone from GitHub**

```bash
cd /root
git clone https://github.com/YOUR_USERNAME/Test
cd Test/MiniLLM-iOS
```

**Option B: Create from files**

```bash
cd /root
mkdir -p MiniLLM-iOS
# Copy your files to /root/MiniLLM-iOS
```

### Step 3: Run Deployment Script

```bash
chmod +x deploy_ish.sh
./deploy_ish.sh
```

**Select option 1** (Cloud Build)

The script will:
1. ✅ Check iSH environment
2. ✅ Prepare project files
3. ✅ Create GitHub Actions workflow
4. ✅ Set up git repository
5. ✅ Provide upload instructions

### Step 4: Create GitHub Repository

**On iPhone in Safari:**

1. Go to **github.com/new**
2. Repository name: **MiniLLM-iOS**
3. Make it **Public**
4. Click **Create repository**
5. Copy the repository URL

### Step 5: Push to GitHub

**Back in iSH:**

```bash
cd /root/Test/MiniLLM-iOS/ish-build

# Add your GitHub repo
git remote add origin https://github.com/YOUR_USERNAME/MiniLLM-iOS.git

# Push code (will trigger build)
git branch -M main
git push -u origin main
```

**Enter your GitHub credentials when prompted**

### Step 6: Monitor Build

**In Safari:**

1. Go to your repository
2. Click **Actions** tab
3. See build progress
4. Wait ~5 minutes
5. Build completes ✅

### Step 7: Download IPA

**After build completes:**

1. Click on the completed workflow
2. Scroll to **Artifacts**
3. Download **MiniLLM-iOS.ipa**
4. IPA saved to Files app

### Step 8: Install with AltStore

**Install AltStore:**

1. On computer: Download **AltServer** from [altstore.io](https://altstore.io)
2. Install AltServer on computer
3. Connect iPhone to computer (USB or WiFi)
4. Open AltServer → Install AltStore to iPhone
5. On iPhone: Trust developer in Settings

**Install MiniLLM:**

1. Open **AltStore** on iPhone
2. Tap **+** (My Apps)
3. Select downloaded **MiniLLM.ipa**
4. Wait for installation
5. App appears on home screen!

### Step 9: Launch

**Tap MiniLLM icon → App launches! 🎉**

---

## 📤 Method 2: Export for Mac (Detailed)

### Step 1: Run Export Script

**In iSH:**

```bash
cd /root/Test/MiniLLM-iOS
./deploy_ish.sh
```

Select option **2** (Export for Mac)

### Step 2: Transfer to Mac

**The script creates: `MiniLLM-iOS-YYYYMMDD-HHMMSS.zip`**

**Transfer via:**

#### Option A: iCloud Drive (Easiest)

1. **In iSH:**
   ```bash
   # Copy to iCloud accessible location
   mkdir -p /root/Documents
   cp MiniLLM-iOS-*.zip /root/Documents/
   ```

2. **On iPhone Files app:**
   - On My iPhone → iSH → Documents
   - Long press ZIP → Share → Save to Files
   - iCloud Drive

3. **On Mac:**
   - Open iCloud Drive
   - Download ZIP

#### Option B: AirDrop

1. **In iSH:**
   ```bash
   # Use iOS share sheet via Python script
   python3 -c "import subprocess; subprocess.call(['open', '.'])"
   ```

2. **Or manually:**
   - Files app → Find ZIP
   - Share → AirDrop → Mac

#### Option C: Email

1. Find ZIP in Files app
2. Share → Mail
3. Send to yourself
4. Download on Mac

### Step 3: Build on Mac

**On Mac:**

```bash
# Extract
unzip MiniLLM-iOS-20240211-123456.zip
cd ish-export/MiniLLM

# Open in Xcode
open MiniLLM.xcodeproj
```

**In Xcode:**
1. Connect iPhone
2. Select iPhone as target
3. Press ⌘R (Run)
4. App installs and launches!

---

## 🐍 Method 3: Pythonista Bridge (Detailed)

### Step 1: Install Pythonista

1. **App Store** → Search "Pythonista 3"
2. Purchase ($9.99)
3. Install and open

### Step 2: Run Deployment Script

**In iSH:**

```bash
cd /root/Test/MiniLLM-iOS
./deploy_ish.sh
```

Select option **3** (Pythonista Bridge)

### Step 3: Copy Script to Pythonista

**Script created at: `/root/Test/MiniLLM-iOS/ish-build/pythonista_build.py`**

**Transfer to Pythonista:**

1. **In Files app:**
   - Navigate to iSH directory
   - Find `pythonista_build.py`
   - Share → Copy

2. **In Pythonista:**
   - Tap **+** (New file)
   - Paste code
   - Save as `build_minillm.py`

### Step 4: Run in Pythonista

**In Pythonista:**

1. Tap `build_minillm.py`
2. Tap ▶️ (Run)
3. Follow on-screen instructions

**Note:** This method is experimental and may require manual setup.

---

## 🛠️ iSH Tips & Tricks

### Useful iSH Commands

```bash
# Check current directory
pwd

# List files
ls -la

# Navigate
cd /root
cd ~/

# Copy files
cp source.txt dest.txt

# Move files
mv old.txt new.txt

# View file
cat file.txt
less file.txt

# Edit file
vi file.txt
nano file.txt  # (if installed)

# Disk space
df -h

# File size
du -sh directory/
```

### Install Text Editor

```bash
# Install nano (easier than vi)
apk add nano

# Use nano
nano file.txt
# Ctrl+O to save, Ctrl+X to exit
```

### Manage Storage

```bash
# Check used space
du -sh /root/*

# Clean up
rm -rf /root/build
apk cache clean
```

### Network Tools

```bash
# Test internet
ping -c 3 google.com

# Download file
curl -O https://example.com/file.zip

# Clone repo
git clone https://github.com/user/repo
```

### Troubleshooting iSH

**iSH crashes or freezes:**
```bash
# Force quit and reopen
# Or restart iPhone
```

**"No space left on device":**
```bash
# Clean up
rm -rf /root/build
apk cache clean

# Or increase storage in iSH settings
```

**"Permission denied":**
```bash
# Make executable
chmod +x script.sh

# Run as root (iSH runs as root by default)
whoami  # Should show "root"
```

---

## 📊 Comparison: iSH vs Mac

| Feature | iSH (iPhone) | Mac |
|---------|--------------|-----|
| **Build Location** | Cloud | Local |
| **Setup Time** | 5 min | 10 min |
| **Build Time** | 5 min | 2 min |
| **Total Time** | 10 min | 12 min |
| **Internet Required** | Yes | No |
| **Mac Required** | No | Yes |
| **Cost** | Free | Mac required |
| **Debugging** | Limited | Full Xcode |
| **Convenience** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🎯 Quick Reference

### One-Command Deploy (iSH)

```bash
cd /root && \
git clone https://github.com/YOUR_USERNAME/Test && \
cd Test/MiniLLM-iOS && \
chmod +x deploy_ish.sh && \
./deploy_ish.sh
```

### GitHub Push (after script)

```bash
cd ish-build
git remote add origin https://github.com/YOUR_USERNAME/MiniLLM-iOS.git
git push -u origin main
```

### Check Build Status

**In Safari:**
```
https://github.com/YOUR_USERNAME/MiniLLM-iOS/actions
```

---

## 🚨 Troubleshooting

### "apk: not found"

```bash
# Update PATH
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

# Try again
apk update
```

### "git: command not found"

```bash
# Install git
apk add git

# Verify
git --version
```

### GitHub push fails

```bash
# Use personal access token instead of password
# GitHub → Settings → Developer settings → Personal access tokens
# Generate token and use as password
```

### iSH can't access files

```bash
# Check permissions in iPhone Settings
# Settings → iSH → Files and Folders → Enable

# Or copy files manually through Files app
```

### Build fails on GitHub

1. Check **Actions** tab for errors
2. Verify all files were pushed:
   ```bash
   git status
   git add -A
   git commit -m "Add missing files"
   git push
   ```
3. Check workflow file syntax

### AltStore installation fails

1. Ensure iTunes is running (Windows) or connected via Finder (Mac)
2. iPhone must trust computer
3. Try WiFi sync instead of USB
4. Reinstall AltServer

---

## 🎉 Success Indicators

You know it worked when:

✅ iSH script completes without errors
✅ GitHub Actions build shows green checkmark
✅ IPA file downloads successfully
✅ AltStore installs without errors
✅ MiniLLM icon appears on iPhone home screen
✅ App launches without crashes
✅ See 5 tabs: Models, Chat, Training, Server, Settings
✅ Can navigate between tabs
✅ Models tab shows 5 models

---

## 🆘 Still Need Help?

### Resources

- **iSH GitHub:** [github.com/ish-app/ish](https://github.com/ish-app/ish)
- **iSH Discord:** Active community support
- **AltStore Guide:** [altstore.io](https://altstore.io)
- **GitHub Actions Docs:** [docs.github.com/actions](https://docs.github.com/actions)

### Common Links

- **App Store - iSH:** [apps.apple.com](https://apps.apple.com/us/app/ish-shell/id1436902243)
- **App Store - Pythonista:** [apps.apple.com](https://apps.apple.com/us/app/pythonista-3/id1085978097)
- **AltStore:** [altstore.io](https://altstore.io)
- **GitHub:** [github.com](https://github.com)

---

## 📱 After Installation

### First Launch

1. **Open MiniLLM**
2. **Allow permissions** (if prompted)
3. **Explore tabs:**
   - 📦 Models - Download & manage
   - 💬 Chat - Conversations
   - 🧠 Training - Datasets
   - 🌐 Server - API
   - ⚙️ Settings - Config

### Quick Test

**1. Load Model:**
- Models tab → TinyLlama → Download → Load

**2. Chat:**
- Chat tab → Type "Hello!" → Send

**3. Train:**
- Training tab → + → Add examples → Train

**4. Server:**
- Server tab → Start Server → Test endpoint

**5. Settings:**
- Settings tab → Check storage → Adjust

---

## 🎊 Congratulations!

You've successfully deployed MiniLLM on your iPhone using iSH!

**What you achieved:**
- ✅ Built iOS app without a Mac
- ✅ Used Linux on iPhone
- ✅ Automated cloud builds
- ✅ Professional deployment

**Next steps:**
- Explore all features
- Customize the UI
- Add real AI models
- Build more apps!

---

<div align="center">

## 🚀 Happy Building!

**iSH + MiniLLM = iPhone Development Freedom** 📱✨

Built with ❤️ for the iOS development community

</div>
