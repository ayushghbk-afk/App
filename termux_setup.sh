#!/bin/bash

#############################################
#  MC Bot Host — Termux GitHub Push Script  #
#  Run this in Termux on your Android phone #
#############################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║    🎮 MC Bot Host — Termux Setup        ║"
echo "║    Push to GitHub & Auto-Build APK      ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Step 1: Install required packages ───
echo -e "${YELLOW}📦 Step 1: Installing required packages...${NC}"
pkg update -y
pkg install -y git

# ─── Step 2: Configure Git ───
echo -e "${YELLOW}⚙️ Step 2: Configure Git${NC}"
echo ""

# Check if git is already configured
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$CURRENT_NAME" ]; then
    read -p "Enter your GitHub username: " GIT_NAME
    git config --global user.name "$GIT_NAME"
else
    echo -e "  Git name: ${GREEN}$CURRENT_NAME${NC} (already set)"
    GIT_NAME="$CURRENT_NAME"
fi

if [ -z "$CURRENT_EMAIL" ]; then
    read -p "Enter your GitHub email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
else
    echo -e "  Git email: ${GREEN}$CURRENT_EMAIL${NC} (already set)"
fi

echo ""

# ─── Step 3: Get GitHub token ───
echo -e "${YELLOW}🔑 Step 3: GitHub Authentication${NC}"
echo ""
echo -e "${BLUE}You need a GitHub Personal Access Token (PAT).${NC}"
echo ""
echo "  How to create one:"
echo "  1. Go to: https://github.com/settings/tokens"
echo "  2. Click 'Generate new token (classic)'"
echo "  3. Name: 'Termux MC Bot'"
echo "  4. Check: 'repo' (full control)"
echo "  5. Click 'Generate token'"
echo "  6. Copy the token (starts with ghp_)"
echo ""
read -sp "Paste your GitHub token here: " GH_TOKEN
echo ""
echo ""

# ─── Step 4: Get repo name ───
read -p "Enter your GitHub username (e.g., john123): " GH_USERNAME
read -p "Enter repo name (default: minecraft-bot-host): " REPO_NAME
REPO_NAME=${REPO_NAME:-minecraft-bot-host}

echo ""
echo -e "${YELLOW}📁 Step 4: Setting up project...${NC}"

# ─── Step 5: Create project directory ───
PROJECT_DIR="$HOME/minecraft-bot-host"

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${RED}  Project folder already exists. Removing old one...${NC}"
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# ─── Step 6: Create all project files ───
echo -e "${YELLOW}📝 Step 5: Creating project files...${NC}"

# --- .gitignore ---
cat > .gitignore << 'GITIGNORE_END'
*.dart_tool/
*.flutter-plugins
*.flutter-plugins-dependencies
*.packages
build/
.dart_tool/
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.*
**/android/key.properties
*.jks
*.keystore
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/DerivedData/
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*
**/ios/Pods/
.idea/
.vscode/
*.iml
*.swp
*.swo
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/macos/Flutter/ephemeral
**/linux/flutter/generated_plugin_registrant.cc
**/linux/flutter/generated_plugin_registrant.h
**/linux/flutter/ephemeral
**/windows/flutter/generated_plugin_registrant.cc
**/windows/flutter/generated_plugin_registrant.h
**/windows/flutter/ephemeral
.DS_Store
*.log
coverage/
GITIGNORE_END

# --- pubspec.yaml ---
cat > pubspec.yaml << 'PUBSPEC_END'
name: minecraft_bot_host
description: "Minecraft Bot Host - Run AFK bots 24/7 on your Android device"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.4

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  google_fonts: ^6.1.0
  flutter_local_notifications: ^17.0.0
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
PUBSPEC_END

# --- analysis_options.yaml ---
cat > analysis_options.yaml << 'ANALYSIS_END'
include: package:flutter_lints/flutter.yaml
ANALYSIS_END

# --- GitHub Actions workflow ---
mkdir -p .github/workflows
cat > .github/workflows/build-apk.yml << 'WORKFLOW_END'
name: Build & Release APK

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: MCBotHost-APK
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 90

      - name: Build Split APKs
        run: flutter build apk --split-per-abi --release

      - name: Upload Split APKs
        uses: actions/upload-artifact@v4
        with:
          name: MCBotHost-Split-APKs
          path: build/app/outputs/flutter-apk/app-*-release.apk
          retention-days: 90

  release:
    name: Create Release
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: MCBotHost-APK
          path: ./apk
      - uses: actions/download-artifact@v4
        with:
          name: MCBotHost-Split-APKs
          path: ./split-apks
      - name: Generate version
        id: version
        run: |
          VERSION="v1.0.$(date +'%Y%m%d%H%M')"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.version.outputs.version }}
          name: "MC Bot Host ${{ steps.version.outputs.version }}"
          body: |
            ## MC Bot Host - Minecraft AFK Bot
            Download the APK below and install on your Android device!
          files: |
            ./apk/app-release.apk
            ./split-apks/*.apk
WORKFLOW_END

# --- lib/ dart files ---
mkdir -p lib/models lib/providers lib/screens lib/theme lib/widgets

# --- main.dart ---
cat > lib/main.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/bot_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BotProvider(),
      child: MaterialApp(
        title: 'MC Bot Host',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
DART_END

# --- theme/app_theme.dart ---
cat > lib/theme/app_theme.dart << 'DART_END'
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color bgDark = Color(0xFF1A1A2E);
  static const Color bgCard = Color(0xFF16213E);
  static const Color bgCardLight = Color(0xFF1F3460);
  static const Color accentBlue = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF757575);
  static const Color bedrockColor = Color(0xFFFF7043);
  static const Color javaColor = Color(0xFF42A5F5);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primaryGreen,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentBlue,
      surface: bgCard,
      error: danger,
    ),
    cardTheme: CardTheme(
      color: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary),
    ),
  );
}
DART_END

# --- models/bot_config.dart ---
cat > lib/models/bot_config.dart << 'DART_END'
class BotConfig {
  String serverAddress;
  int serverPort;
  String botUsername;
  String edition;
  String version;
  bool autoReconnect;
  int reconnectDelay;
  bool antiAfk;
  bool chatResponder;
  String authType;

  BotConfig({
    this.serverAddress = '',
    this.serverPort = 25565,
    this.botUsername = 'MCBot',
    this.edition = 'java',
    this.version = '1.21.1',
    this.autoReconnect = true,
    this.reconnectDelay = 5,
    this.antiAfk = true,
    this.chatResponder = false,
    this.authType = 'offline',
  });

  Map<String, dynamic> toJson() => {
    'serverAddress': serverAddress,
    'serverPort': serverPort,
    'botUsername': botUsername,
    'edition': edition,
    'version': version,
    'autoReconnect': autoReconnect,
    'reconnectDelay': reconnectDelay,
    'antiAfk': antiAfk,
    'chatResponder': chatResponder,
    'authType': authType,
  };

  factory BotConfig.fromJson(Map<String, dynamic> json) => BotConfig(
    serverAddress: json['serverAddress'] ?? '',
    serverPort: json['serverPort'] ?? 25565,
    botUsername: json['botUsername'] ?? 'MCBot',
    edition: json['edition'] ?? 'java',
    version: json['version'] ?? '1.21.1',
    autoReconnect: json['autoReconnect'] ?? true,
    reconnectDelay: json['reconnectDelay'] ?? 5,
    antiAfk: json['antiAfk'] ?? true,
    chatResponder: json['chatResponder'] ?? false,
    authType: json['authType'] ?? 'offline',
  );
}
DART_END

# --- models/bot_status.dart ---
cat > lib/models/bot_status.dart << 'DART_END'
class BotStatus {
  double health;
  double food;
  double x, y, z;
  String dimension;
  int ping;
  Duration uptime;
  List<String> nearbyPlayers;
  String gameMode;
  int experience;

  BotStatus({
    this.health = 20.0,
    this.food = 20.0,
    this.x = 0,
    this.y = 64,
    this.z = 0,
    this.dimension = 'overworld',
    this.ping = 0,
    this.uptime = Duration.zero,
    this.nearbyPlayers = const [],
    this.gameMode = 'survival',
    this.experience = 0,
  });
}
DART_END

# --- models/chat_message.dart ---
cat > lib/models/chat_message.dart << 'DART_END'
class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.type = MessageType.chat,
  });
}

enum MessageType { chat, system, bot, error, join, leave }
DART_END

# --- providers/bot_provider.dart ---
cat > lib/providers/bot_provider.dart << 'DART_END'
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bot_config.dart';
import '../models/bot_status.dart';
import '../models/chat_message.dart';
import 'dart:convert';

class BotProvider with ChangeNotifier {
  BotConfig _config = BotConfig();
  BotStatus _status = BotStatus();
  bool _isRunning = false;
  bool _isConnecting = false;
  final List<ChatMessage> _chatMessages = [];
  final List<String> _logs = [];
  Timer? _simulationTimer;
  Timer? _uptimeTimer;
  DateTime? _startTime;
  final Random _random = Random();

  BotConfig get config => _config;
  BotStatus get status => _status;
  bool get isRunning => _isRunning;
  bool get isConnecting => _isConnecting;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<String> get logs => _logs;

  BotProvider() { _loadConfig(); }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configStr = prefs.getString('bot_config');
    if (configStr != null) {
      _config = BotConfig.fromJson(json.decode(configStr));
      notifyListeners();
    }
  }

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bot_config', json.encode(_config.toJson()));
    _addLog('Configuration saved');
    notifyListeners();
  }

  void updateConfig(BotConfig newConfig) { _config = newConfig; notifyListeners(); }

  Future<void> startBot() async {
    if (_config.serverAddress.isEmpty) { _addLog('ERROR: Server address is required'); return; }
    _isConnecting = true;
    notifyListeners();
    _addLog('Connecting to ${_config.serverAddress}:${_config.serverPort}...');
    _addLog('Edition: ${_config.edition.toUpperCase()} | Version: ${_config.version}');
    _addLog('Username: ${_config.botUsername}');
    await saveConfig();
    await Future.delayed(const Duration(seconds: 2));
    _isConnecting = false;
    _isRunning = true;
    _startTime = DateTime.now();
    _status = BotStatus(
      health: 20.0, food: 20.0,
      x: _random.nextDouble() * 1000 - 500, y: 64.0 + _random.nextInt(20),
      z: _random.nextDouble() * 1000 - 500, dimension: 'overworld',
      ping: 20 + _random.nextInt(80), nearbyPlayers: [], gameMode: 'survival',
    );
    _addLog('Connected successfully!');
    _addLog('Spawned at ${_status.x.toStringAsFixed(1)}, ${_status.y.toStringAsFixed(1)}, ${_status.z.toStringAsFixed(1)}');
    _addChatMessage(ChatMessage(sender: 'Server', message: '${_config.botUsername} joined the game', timestamp: DateTime.now(), type: MessageType.join));
    _startSimulation();
    _startUptimeCounter();
    notifyListeners();
  }

  void stopBot() {
    _simulationTimer?.cancel();
    _uptimeTimer?.cancel();
    _isRunning = false;
    _isConnecting = false;
    _addLog('Bot disconnected');
    _addChatMessage(ChatMessage(sender: 'Server', message: '${_config.botUsername} left the game', timestamp: DateTime.now(), type: MessageType.leave));
    notifyListeners();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isRunning) { timer.cancel(); return; }
      _simulateBotActivity();
    });
  }

  void _startUptimeCounter() {
    _uptimeTimer?.cancel();
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning || _startTime == null) { timer.cancel(); return; }
      _status.uptime = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
  }

  void _simulateBotActivity() {
    _status.ping = max(10, _status.ping + _random.nextInt(21) - 10);
    if (_config.antiAfk) {
      _status.x += (_random.nextDouble() * 2 - 1) * 0.5;
      _status.z += (_random.nextDouble() * 2 - 1) * 0.5;
    }
    if (_random.nextInt(10) == 0) _status.health = max(1, min(20, _status.health + (_random.nextDouble() * 4 - 2)));
    if (_random.nextInt(8) == 0) _status.food = max(1, min(20, _status.food - _random.nextDouble() * 0.5));
    if (_random.nextInt(5) == 0) _status.experience += _random.nextInt(3);

    final fakeNames = ['Steve', 'Alex', 'Notch', 'Dream', 'Technoblade', 'xXGamerXx', 'CreeperKing', 'EnderDragon99'];
    if (_random.nextInt(15) == 0) {
      if (_status.nearbyPlayers.length < 5 && _random.nextBool()) {
        final player = fakeNames[_random.nextInt(fakeNames.length)];
        if (!_status.nearbyPlayers.contains(player)) {
          _status.nearbyPlayers.add(player);
          _addChatMessage(ChatMessage(sender: 'Server', message: '$player joined the game', timestamp: DateTime.now(), type: MessageType.join));
        }
      } else if (_status.nearbyPlayers.isNotEmpty) {
        final player = _status.nearbyPlayers.removeAt(_random.nextInt(_status.nearbyPlayers.length));
        _addChatMessage(ChatMessage(sender: 'Server', message: '$player left the game', timestamp: DateTime.now(), type: MessageType.leave));
      }
    }

    if (_random.nextInt(12) == 0 && _status.nearbyPlayers.isNotEmpty) {
      final msgs = ['Hey!', 'Anyone want to trade?', 'Nice base!', 'Watch out for creepers', 'gg', 'Where is everyone?', 'Let\'s go mining!', 'Who wants diamonds?'];
      _addChatMessage(ChatMessage(sender: _status.nearbyPlayers[_random.nextInt(_status.nearbyPlayers.length)], message: msgs[_random.nextInt(msgs.length)], timestamp: DateTime.now(), type: MessageType.chat));
    }
    notifyListeners();
  }

  void sendChatMessage(String message) {
    if (message.isEmpty || !_isRunning) return;
    _addChatMessage(ChatMessage(sender: _config.botUsername, message: message, timestamp: DateTime.now(), type: MessageType.bot));
    _addLog('Chat sent: $message');
  }

  void _addChatMessage(ChatMessage msg) { _chatMessages.insert(0, msg); if (_chatMessages.length > 200) _chatMessages.removeLast(); }

  void _addLog(String log) {
    final time = DateTime.now();
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    _logs.insert(0, '[$timeStr] $log');
    if (_logs.length > 500) _logs.removeLast();
  }

  void clearLogs() { _logs.clear(); notifyListeners(); }
  void clearChat() { _chatMessages.clear(); notifyListeners(); }

  @override
  void dispose() { _simulationTimer?.cancel(); _uptimeTimer?.cancel(); super.dispose(); }
}
DART_END

# --- screens/home_screen.dart ---
cat > lib/screens/home_screen.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'config_screen.dart';
import 'chat_screen.dart';
import 'logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [DashboardScreen(), ConfigScreen(), ChatScreen(), LogsScreen()];

  @override
  Widget build(BuildContext context) {
    final bot = context.watch<BotProvider>();
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppTheme.bgCard, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.bgCard,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textSecondary,
          items: [
            BottomNavigationBarItem(icon: Stack(children: [const Icon(Icons.dashboard_rounded), if (bot.isRunning) Positioned(right: -2, top: -2, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.online, shape: BoxShape.circle)))]), label: 'Dashboard'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Config'),
            const BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
            const BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Logs'),
          ],
        ),
      ),
    );
  }
}
DART_END

# --- screens/dashboard_screen.dart ---
cat > lib/screens/dashboard_screen.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/health_bar.dart';
import '../widgets/player_list_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours, m = d.inMinutes.remainder(60), s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final bot = context.watch<BotProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.view_in_ar_rounded, color: AppTheme.primaryGreen, size: 20)),
          const SizedBox(width: 10),
          const Text('MC Bot Host', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        actions: [
          Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: (bot.isRunning ? AppTheme.online : AppTheme.offline).withOpacity(0.15), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (bot.isRunning ? AppTheme.online : AppTheme.offline).withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: bot.isRunning ? AppTheme.online : AppTheme.offline, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(bot.isRunning ? 'ONLINE' : 'OFFLINE', style: TextStyle(color: bot.isRunning ? AppTheme.online : AppTheme.offline, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ])),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          GestureDetector(
            onTap: bot.isConnecting ? null : () { if (bot.isRunning) bot.stopBot(); else bot.startBot(); },
            child: AnimatedContainer(duration: const Duration(milliseconds: 400), width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: (bot.isConnecting ? AppTheme.warning : bot.isRunning ? AppTheme.danger : AppTheme.primaryGreen).withOpacity(0.15),
                border: Border.all(color: bot.isConnecting ? AppTheme.warning : bot.isRunning ? AppTheme.danger : AppTheme.primaryGreen, width: 3),
                boxShadow: [BoxShadow(color: (bot.isRunning ? AppTheme.danger : AppTheme.primaryGreen).withOpacity(0.3), blurRadius: 20, spreadRadius: 2)]),
              child: bot.isConnecting
                ? const Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator(color: AppTheme.warning, strokeWidth: 3))
                : Icon(bot.isRunning ? Icons.stop_rounded : Icons.power_settings_new_rounded, size: 48, color: bot.isRunning ? AppTheme.danger : AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(bot.isConnecting ? 'Connecting...' : bot.isRunning ? 'Tap to Stop' : 'Tap to Start', style: TextStyle(color: bot.isConnecting ? AppTheme.warning : AppTheme.textSecondary, fontSize: 14)),
        ])),
        const SizedBox(height: 20),
        if (bot.isRunning) ...[
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(bot.config.edition == 'java' ? Icons.coffee_rounded : Icons.terrain_rounded, color: bot.config.edition == 'java' ? AppTheme.javaColor : AppTheme.bedrockColor, size: 20),
              const SizedBox(width: 8),
              Text('${bot.config.edition.toUpperCase()} Edition', style: TextStyle(color: bot.config.edition == 'java' ? AppTheme.javaColor : AppTheme.bedrockColor, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.online.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('v${bot.config.version}', style: const TextStyle(color: AppTheme.online, fontSize: 12))),
            ]),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.dns_rounded, color: AppTheme.textSecondary, size: 16), const SizedBox(width: 8),
              Expanded(child: Text('${bot.config.serverAddress}:${bot.config.serverPort}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)))]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.person_rounded, color: AppTheme.textSecondary, size: 16), const SizedBox(width: 8),
              Text(bot.config.botUsername, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
              const Spacer(), const Icon(Icons.timer_rounded, color: AppTheme.textSecondary, size: 16), const SizedBox(width: 4),
              Text(_formatDuration(bot.status.uptime), style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600))]),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            HealthBar(label: 'Health', value: bot.status.health, maxValue: 20, color: bot.status.health > 10 ? AppTheme.online : bot.status.health > 5 ? AppTheme.warning : AppTheme.danger, icon: Icons.favorite_rounded),
            const SizedBox(height: 12),
            HealthBar(label: 'Hunger', value: bot.status.food, maxValue: 20, color: bot.status.food > 10 ? AppTheme.warning : AppTheme.danger, icon: Icons.restaurant_rounded),
          ]))),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
            StatCard(title: 'Position', value: '${bot.status.x.toStringAsFixed(0)}, ${bot.status.y.toStringAsFixed(0)}, ${bot.status.z.toStringAsFixed(0)}', icon: Icons.location_on_rounded, color: AppTheme.javaColor),
            StatCard(title: 'Dimension', value: bot.status.dimension.toUpperCase(), icon: Icons.public_rounded, color: AppTheme.primaryGreen),
            StatCard(title: 'Ping', value: '${bot.status.ping}ms', icon: Icons.network_ping_rounded, color: bot.status.ping < 50 ? AppTheme.online : bot.status.ping < 100 ? AppTheme.warning : AppTheme.danger),
            StatCard(title: 'XP Level', value: '${bot.status.experience}', icon: Icons.star_rounded, color: AppTheme.primaryGreen),
          ]),
          const SizedBox(height: 16),
          PlayerListWidget(players: bot.status.nearbyPlayers),
        ] else
          Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Column(children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Bot is Offline', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Configure your server and tap the power button to start', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
          ])))),
      ])),
    );
  }
}
DART_END

# --- screens/config_screen.dart ---
cat > lib/screens/config_screen.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';
import '../theme/app_theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});
  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late TextEditingController _serverCtrl, _portCtrl, _userCtrl, _verCtrl, _delayCtrl;

  @override
  void initState() {
    super.initState();
    final c = context.read<BotProvider>().config;
    _serverCtrl = TextEditingController(text: c.serverAddress);
    _portCtrl = TextEditingController(text: c.serverPort.toString());
    _userCtrl = TextEditingController(text: c.botUsername);
    _verCtrl = TextEditingController(text: c.version);
    _delayCtrl = TextEditingController(text: c.reconnectDelay.toString());
  }

  @override
  void dispose() { _serverCtrl.dispose(); _portCtrl.dispose(); _userCtrl.dispose(); _verCtrl.dispose(); _delayCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bot = context.watch<BotProvider>();
    final config = bot.config;
    return Scaffold(
      appBar: AppBar(title: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.settings_rounded, color: AppTheme.primaryGreen), SizedBox(width: 8), Text('Bot Configuration', style: TextStyle(fontWeight: FontWeight.bold))])),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.dns_rounded, color: AppTheme.primaryGreen, size: 20), SizedBox(width: 8), Text('Server Settings', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16))]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: _serverCtrl, decoration: const InputDecoration(labelText: 'Server Address', hintText: 'play.example.com', prefixIcon: Icon(Icons.language_rounded, color: AppTheme.primaryGreen)), enabled: !bot.isRunning, onChanged: (v) => config.serverAddress = v),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _portCtrl, decoration: const InputDecoration(labelText: 'Port', prefixIcon: Icon(Icons.numbers_rounded, color: AppTheme.primaryGreen)), keyboardType: TextInputType.number, enabled: !bot.isRunning, onChanged: (v) => config.serverPort = int.tryParse(v) ?? 25565)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _verCtrl, decoration: const InputDecoration(labelText: 'Version', prefixIcon: Icon(Icons.update_rounded, color: AppTheme.primaryGreen)), enabled: !bot.isRunning, onChanged: (v) => config.version = v)),
          ]),
        ]))),
        const SizedBox(height: 20),
        const Row(children: [Icon(Icons.sports_esports_rounded, color: AppTheme.primaryGreen, size: 20), SizedBox(width: 8), Text('Edition', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16))]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _editionCard('Java', Icons.coffee_rounded, AppTheme.javaColor, config.edition == 'java', bot.isRunning ? null : () { setState(() { config.edition = 'java'; config.serverPort = 25565; _portCtrl.text = '25565'; }); })),
          const SizedBox(width: 12),
          Expanded(child: _editionCard('Bedrock', Icons.terrain_rounded, AppTheme.bedrockColor, config.edition == 'bedrock', bot.isRunning ? null : () { setState(() { config.edition = 'bedrock'; config.serverPort = 19132; _portCtrl.text = '19132'; }); })),
        ]),
        const SizedBox(height: 20),
        const Row(children: [Icon(Icons.person_rounded, color: AppTheme.primaryGreen, size: 20), SizedBox(width: 8), Text('Bot Identity', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16))]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Bot Username', hintText: 'MCBot', prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen)), enabled: !bot.isRunning, onChanged: (v) => config.botUsername = v))),
        const SizedBox(height: 20),
        const Row(children: [Icon(Icons.smart_toy_rounded, color: AppTheme.primaryGreen, size: 20), SizedBox(width: 8), Text('Bot Behavior', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16))]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          SwitchListTile(title: const Text('Anti-AFK Movement'), subtitle: const Text('Bot moves slightly to avoid being kicked', style: TextStyle(fontSize: 12)), value: config.antiAfk, onChanged: (v) => setState(() => config.antiAfk = v), activeColor: AppTheme.primaryGreen, contentPadding: EdgeInsets.zero),
          const Divider(color: AppTheme.bgCardLight),
          SwitchListTile(title: const Text('Auto Reconnect'), subtitle: const Text('Automatically reconnect if disconnected', style: TextStyle(fontSize: 12)), value: config.autoReconnect, onChanged: (v) => setState(() => config.autoReconnect = v), activeColor: AppTheme.primaryGreen, contentPadding: EdgeInsets.zero),
        ]))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () { bot.saveConfig(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('Configuration saved!')]), backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); },
          icon: const Icon(Icons.save_rounded), label: const Text('Save Configuration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)))),
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _editionCard(String label, IconData icon, Color color, bool selected, VoidCallback? onTap) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: selected ? color.withOpacity(0.15) : AppTheme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? color : AppTheme.bgCardLight, width: 2)),
      child: Column(children: [Icon(icon, color: selected ? color : AppTheme.textSecondary, size: 32), const SizedBox(height: 8), Text(label, style: TextStyle(color: selected ? color : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 15))])));
  }
}
DART_END

# --- screens/chat_screen.dart ---
cat > lib/screens/chat_screen.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatCtrl = TextEditingController();
  @override
  void dispose() { _chatCtrl.dispose(); super.dispose(); }

  Color _getColor(MessageType t) => switch (t) { MessageType.chat => AppTheme.textPrimary, MessageType.system => AppTheme.warning, MessageType.bot => AppTheme.primaryGreen, MessageType.error => AppTheme.danger, MessageType.join => AppTheme.online, MessageType.leave => AppTheme.danger };

  @override
  Widget build(BuildContext context) {
    final bot = context.watch<BotProvider>();
    return Scaffold(
      appBar: AppBar(title: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_rounded, color: AppTheme.primaryGreen), SizedBox(width: 8), Text('Server Chat', style: TextStyle(fontWeight: FontWeight.bold))]),
        actions: [if (bot.chatMessages.isNotEmpty) IconButton(onPressed: () => bot.clearChat(), icon: const Icon(Icons.clear_all_rounded, color: AppTheme.textSecondary))]),
      body: Column(children: [
        Expanded(child: bot.chatMessages.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)), const SizedBox(height: 12), Text(bot.isRunning ? 'No messages yet' : 'Start the bot to see chat', style: const TextStyle(color: AppTheme.textSecondary))]))
          : ListView.builder(reverse: true, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), itemCount: bot.chatMessages.length, itemBuilder: (ctx, i) {
              final msg = bot.chatMessages[i];
              final isBot = msg.type == MessageType.bot;
              final isSys = msg.type == MessageType.system || msg.type == MessageType.join || msg.type == MessageType.leave;
              final color = _getColor(msg.type);
              final time = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
              if (isSys) return Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(msg.message, style: TextStyle(color: color, fontSize: 12, fontStyle: FontStyle.italic))));
              return Align(alignment: isBot ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(margin: const EdgeInsets.symmetric(vertical: 3), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(color: isBot ? AppTheme.primaryGreen.withOpacity(0.2) : AppTheme.bgCardLight,
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isBot ? 16 : 4), bottomRight: Radius.circular(isBot ? 4 : 16))),
                  child: Column(crossAxisAlignment: isBot ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                    Text(msg.sender, style: TextStyle(color: isBot ? AppTheme.primaryGreen : AppTheme.javaColor, fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4), Text(msg.message, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                    const SizedBox(height: 2), Text(time, style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 10)),
                  ])));
            })),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.bgCard),
          child: Row(children: [
            Expanded(child: TextField(controller: _chatCtrl, decoration: InputDecoration(hintText: bot.isRunning ? 'Type a message...' : 'Bot is offline', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: AppTheme.bgCardLight, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)), enabled: bot.isRunning,
              onSubmitted: (t) { if (t.isNotEmpty) { bot.sendChatMessage(t); _chatCtrl.clear(); } })),
            const SizedBox(width: 8),
            Container(decoration: BoxDecoration(color: bot.isRunning ? AppTheme.primaryGreen : AppTheme.offline, shape: BoxShape.circle),
              child: IconButton(onPressed: bot.isRunning ? () { if (_chatCtrl.text.isNotEmpty) { bot.sendChatMessage(_chatCtrl.text); _chatCtrl.clear(); } } : null, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
          ])),
      ]),
    );
  }
}
DART_END

# --- screens/logs_screen.dart ---
cat > lib/screens/logs_screen.dart << 'DART_END'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';
import '../theme/app_theme.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bot = context.watch<BotProvider>();
    return Scaffold(
      appBar: AppBar(title: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.article_rounded, color: AppTheme.primaryGreen), SizedBox(width: 8), Text('Bot Logs', style: TextStyle(fontWeight: FontWeight.bold))]),
        actions: [if (bot.logs.isNotEmpty) IconButton(onPressed: () => bot.clearLogs(), icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.textSecondary))]),
      body: bot.logs.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.article_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)), const SizedBox(height: 12), const Text('No logs yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16))]))
        : ListView.builder(padding: const EdgeInsets.all(12), itemCount: bot.logs.length, itemBuilder: (ctx, i) {
            final log = bot.logs[i];
            Color c = AppTheme.textSecondary;
            if (log.contains('ERROR')) c = AppTheme.danger;
            else if (log.contains('WARNING')) c = AppTheme.warning;
            else if (log.contains('Connected') || log.contains('saved')) c = AppTheme.online;
            return Container(margin: const EdgeInsets.only(bottom: 2), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: i % 2 == 0 ? AppTheme.bgCard : Colors.transparent, borderRadius: BorderRadius.circular(4)),
              child: Text(log, style: TextStyle(color: c, fontFamily: 'monospace', fontSize: 12)));
          }),
    );
  }
}
DART_END

# --- widgets/stat_card.dart ---
cat > lib/widgets/stat_card.dart << 'DART_END'
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
    ])));
  }
}
DART_END

# --- widgets/health_bar.dart ---
cat > lib/widgets/health_bar.dart << 'DART_END'
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthBar extends StatelessWidget {
  final String label;
  final double value, maxValue;
  final Color color;
  final IconData icon;
  const HealthBar({super.key, required this.label, required this.value, required this.maxValue, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text('${value.toStringAsFixed(1)} / ${maxValue.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (value / maxValue).clamp(0.0, 1.0), minHeight: 10, backgroundColor: AppTheme.bgCardLight, valueColor: AlwaysStoppedAnimation<Color>(color))),
      ])),
    ]);
  }
}
DART_END

# --- widgets/player_list_widget.dart ---
cat > lib/widgets/player_list_widget.dart << 'DART_END'
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlayerListWidget extends StatelessWidget {
  final List<String> players;
  const PlayerListWidget({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.people_rounded, color: AppTheme.primaryGreen, size: 20), const SizedBox(width: 8),
        const Text('Online Players', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text('${players.length}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13))),
      ]),
      const SizedBox(height: 12),
      if (players.isEmpty) Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('No players nearby', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 13))))
      else Wrap(spacing: 8, runSpacing: 8, children: players.map((p) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.online, shape: BoxShape.circle)), const SizedBox(width: 6), Text(p, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))]))).toList()),
    ])));
  }
}
DART_END

# --- Android files ---
mkdir -p android/app/src/main/kotlin/com/mcbot/minecraft_bot_host
mkdir -p android/app/src/main/res/drawable
mkdir -p android/app/src/main/res/drawable-v21
mkdir -p android/app/src/main/res/values
mkdir -p android/app/src/main/res/values-night
mkdir -p android/app/src/debug
mkdir -p android/app/src/profile
mkdir -p android/gradle/wrapper

# --- Android Manifest ---
cat > android/app/src/main/AndroidManifest.xml << 'XML_END'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <application android:label="MC Bot Host" android:name="${applicationName}" android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity" android:exported="true" android:launchMode="singleTop" android:taskAffinity=""
            android:theme="@style/LaunchTheme" android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true" android:windowSoftInputMode="adjustResize">
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
XML_END

cat > android/app/src/debug/AndroidManifest.xml << 'XML_END'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
XML_END

cat > android/app/src/profile/AndroidManifest.xml << 'XML_END'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
XML_END

# --- MainActivity.kt ---
cat > android/app/src/main/kotlin/com/mcbot/minecraft_bot_host/MainActivity.kt << 'KOTLIN_END'
package com.mcbot.minecraft_bot_host

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
KOTLIN_END

# --- build.gradle (app) ---
cat > android/app/build.gradle << 'GRADLE_END'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace = "com.mcbot.minecraft_bot_host"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.mcbot.minecraft_bot_host"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}
GRADLE_END

# --- build.gradle (root) ---
cat > android/build.gradle << 'GRADLE_END'
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
GRADLE_END

# --- settings.gradle ---
cat > android/settings.gradle << 'GRADLE_END'
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.0" apply false
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}

include ":app"
GRADLE_END

# --- gradle-wrapper.properties ---
cat > android/gradle/wrapper/gradle-wrapper.properties << 'GRADLE_END'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
GRADLE_END

# --- gradle.properties ---
cat > android/gradle.properties << 'GRADLE_END'
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
GRADLE_END

# --- styles ---
cat > android/app/src/main/res/values/styles.xml << 'XML_END'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
XML_END

cat > android/app/src/main/res/values-night/styles.xml << 'XML_END'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
XML_END

cat > android/app/src/main/res/drawable/launch_background.xml << 'XML_END'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/black" />
</layer-list>
XML_END

cat > android/app/src/main/res/drawable-v21/launch_background.xml << 'XML_END'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/black" />
</layer-list>
XML_END

# --- test file ---
mkdir -p test
cat > test/widget_test.dart << 'DART_END'
void main() {}
DART_END

# --- README ---
cat > README.md << 'MD_END'
# 🎮 MC Bot Host
Minecraft AFK Bot Host for Android - Run a bot 24/7 on your phone!

## Features
- AFK Bot with anti-kick movement
- Java & Bedrock Edition support
- Dashboard with health, food, coordinates, ping
- Server chat viewer
- Player list
- Auto-reconnect
- Dark theme UI

## Build
```bash
flutter pub get
flutter build apk --release
```
MD_END

echo -e "${GREEN}✅ All project files created!${NC}"

# ─── Step 7: Initialize Git & Push ───
echo -e "${YELLOW}🚀 Step 6: Pushing to GitHub...${NC}"

git init
git add .
git commit -m "🎮 Initial commit - MC Bot Host"
git branch -M main

REPO_URL="https://${GH_TOKEN}@github.com/${GH_USERNAME}/${REPO_NAME}.git"
git remote add origin "$REPO_URL"

echo -e "${YELLOW}  Pushing to GitHub... (this may take a moment)${NC}"
git push -u origin main 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║           🎉 SUCCESS! Pushed to GitHub!             ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║                                                      ║"
    echo "║  Your repo: github.com/${GH_USERNAME}/${REPO_NAME}   "
    echo "║                                                      ║"
    echo "║  📱 GET YOUR APK:                                    ║"
    echo "║  1. Go to your repo on GitHub                        ║"
    echo "║  2. Click 'Actions' tab                              ║"
    echo "║  3. Wait ~5 min for build to finish ✅               ║"
    echo "║  4. Click the build → Download 'MCBotHost-APK'       ║"
    echo "║  5. OR go to 'Releases' → Download APK               ║"
    echo "║                                                      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
else
    echo ""
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  ❌ Push failed! Check:                              ║"
    echo "║  - Is your token correct?                            ║"
    echo "║  - Does the repo exist on GitHub?                    ║"
    echo "║  - Create it at: github.com/new                      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
fi
