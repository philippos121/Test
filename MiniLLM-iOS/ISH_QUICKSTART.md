# 📱 iSH Quick Start - MiniLLM iOS

**Deploy MiniLLM on iPhone using iSH in 5 minutes!**

---

## 🚀 One-Command Install

**In iSH:**

```bash
cd /root && \
apk update && apk add git curl zip && \
git clone <YOUR_REPO> && \
cd MiniLLM-iOS && \
./deploy_ish.sh
```

Choose **1** (Cloud Build) → Follow prompts!

---

## 📋 Step-by-Step (5 minutes)

### 1️⃣ Install iSH (1 min)
- App Store → "iSH Shell" → Install

### 2️⃣ Setup Tools (1 min)
```bash
apk update
apk add git curl zip unzip
```

### 3️⃣ Clone Project (30 sec)
```bash
cd /root
git clone https://github.com/YOUR_USERNAME/Test
cd Test/MiniLLM-iOS
```

### 4️⃣ Deploy (30 sec)
```bash
chmod +x deploy_ish.sh
./deploy_ish.sh
```
Select **1** for Cloud Build

### 5️⃣ Push to GitHub (1 min)
```bash
cd ish-build
git remote add origin <YOUR_REPO>
git push -u origin main
```

### 6️⃣ Get IPA (5 min wait)
- Safari → github.com/YOUR_USERNAME/MiniLLM-iOS
- Actions tab → Wait for build
- Download IPA artifact

### 7️⃣ Install (1 min)
- AltStore → + → Open IPA → Install
- Launch MiniLLM! 🎉

---

## 🎯 Quick Commands

### Update project
```bash
cd /root/Test/MiniLLM-iOS
git pull
./deploy_ish.sh
```

### Clean rebuild
```bash
rm -rf ish-build
./deploy_ish.sh
```

### Check build status
**Safari:** `github.com/YOUR_USERNAME/MiniLLM-iOS/actions`

---

## 🆘 Quick Fixes

### "apk: not found"
```bash
export PATH="/bin:/usr/bin:/sbin:/usr/sbin"
apk update
```

### "git: command not found"
```bash
apk add git
```

### Push fails
- Use Personal Access Token (not password)
- GitHub → Settings → Developer settings → Tokens

### iSH crashes
- Force quit and reopen
- Or restart iPhone

---

## 📞 Need Help?

**Full Guide:** [ISH_DEPLOY.md](ISH_DEPLOY.md)

**Common Issues:**
- No Mac required!
- Free GitHub Actions
- AltStore guide: [altstore.io](https://altstore.io)
- Build time: ~5 minutes

---

## ✅ Success Checklist

- [ ] iSH installed
- [ ] Tools installed (git, curl, zip)
- [ ] Project cloned
- [ ] Script ran successfully
- [ ] Pushed to GitHub
- [ ] Build completed (green ✓)
- [ ] IPA downloaded
- [ ] AltStore installed
- [ ] MiniLLM installed
- [ ] App launches!

---

<div align="center">

**🎉 That's it! Enjoy MiniLLM on iPhone!**

**Total time: 5 minutes** ⚡

**No Mac needed!** 📱

</div>
