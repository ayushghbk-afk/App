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
