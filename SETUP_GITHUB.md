# 🚀 GitHub Setup Guide — Get Your APK in 5 Minutes!

## Step-by-Step Instructions

### Step 1: Create a GitHub Repository
1. Go to [github.com/new](https://github.com/new)
2. Name it: `minecraft-bot-host`
3. Set it to **Public** (or Private, both work)
4. **DON'T** add README or .gitignore (we already have them)
5. Click **Create Repository**

### Step 2: Download Project Files
1. Download ALL files from the workspace `minecraft_bot_host/` folder
2. Make sure you have these folders:
   ```
   minecraft_bot_host/
   ├── .github/
   │   └── workflows/
   │       └── build-apk.yml    ← This triggers auto-build!
   ├── android/
   ├── lib/
   ├── pubspec.yaml
   ├── .gitignore
   └── README.md
   ```

### Step 3: Push to GitHub
Open terminal in the project folder and run:

```bash
cd minecraft_bot_host
git init
git add .
git commit -m "Initial commit - MC Bot Host"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/minecraft-bot-host.git
git push -u origin main
```

### Step 4: Watch it Build! 🎉
1. Go to your GitHub repo
2. Click the **"Actions"** tab
3. You'll see **"Build & Release APK"** running
4. Wait ~3-5 minutes for it to finish ✅

### Step 5: Download Your APK
**Option A — From Artifacts (every build):**
1. Click on the completed workflow run
2. Scroll down to **"Artifacts"**
3. Click **"MCBotHost-APK"** to download the zip
4. Extract → you have `app-release.apk`!

**Option B — From Releases (auto-created):**
1. Go to your repo's **"Releases"** page
2. Find the latest release
3. Download `app-release.apk` directly!

---

## 🔄 Want to Update the App?
Just push new code to `main` branch:
```bash
git add .
git commit -m "Updated feature X"
git push
```
GitHub Actions will **automatically rebuild** and create a new release!

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | Check Actions tab for error logs |
| Can't install APK | Enable "Unknown Sources" in Android settings |
| Actions tab missing | Go to Settings → Actions → Enable workflows |

## 🔑 Signing the APK (Optional)
For a production-ready signed APK, add these secrets in GitHub:
- `Settings → Secrets → Actions`
- Add your keystore as base64 encoded secret
