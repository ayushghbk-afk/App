# 🎮 MC Bot Host

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue?logo=flutter)
![Android](https://img.shields.io/badge/Android-5.0%2B-green?logo=android)
![License](https://img.shields.io/badge/License-MIT-yellow)

**Minecraft AFK Bot Host for Android**

Run a Minecraft bot 24/7 on your Android device with a beautiful dashboard.

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎮 **AFK Bot** | Stays online, anti-kick movement, keeps chunks loaded |
| ☕ **Java Edition** | Full support for Java Edition servers |
| 🪨 **Bedrock Edition** | Full support for Bedrock Edition servers |
| 📊 **Dashboard** | Health, food, coordinates, ping, XP, uptime |
| 💬 **Chat** | View server chat, send messages, see join/leave events |
| 👥 **Player List** | See online players nearby |
| 🔄 **Auto-Reconnect** | Automatically reconnects if disconnected |
| 📋 **Logs** | Detailed color-coded activity logs |
| 🌙 **Dark Theme** | Beautiful dark UI with green accents |
| ⚡ **Background Service** | Runs in background with wake lock |

## 📸 Screenshots

Coming soon!

## 📥 Installation

### Download APK
1. Go to [Releases](../../releases)
2. Download the latest `app-release.apk`
3. Install on your Android device
4. Enable "Install from Unknown Sources" if prompted

### Build from Source
```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/minecraft-bot-host.git
cd minecraft-bot-host

# Install dependencies
flutter pub get

# Build APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 🚀 Usage

1. **Open the app** on your Android device
2. Go to **Config** tab
3. Enter your **server address** and **port**
4. Set your **bot username**
5. Choose **Java** or **Bedrock** edition
6. Go to **Dashboard** → Tap the **power button**
7. Monitor via Dashboard, Chat, and Logs tabs!

## 🛠️ Tech Stack

- **Flutter** 3.24.5
- **Dart** 3.5.4
- **Provider** for state management
- **SharedPreferences** for persistent config
- **Material Design 3** UI

## 📋 Permissions

| Permission | Reason |
|-----------|--------|
| `INTERNET` | Connect to Minecraft servers |
| `FOREGROUND_SERVICE` | Keep bot running in background |
| `WAKE_LOCK` | Prevent device from sleeping |
| `POST_NOTIFICATIONS` | Show bot status notifications |

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

## 📄 License

MIT License - feel free to use and modify!

---

<div align="center">
Made with ❤️ using Flutter
</div>
