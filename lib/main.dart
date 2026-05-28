import 'package:flutter/material.dart';
import './screens/auth_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RaphaelApp());
}

class RaphaelApp extends StatefulWidget {
  const RaphaelApp({super.key});

  @override
  State<RaphaelApp> createState() => _RaphaelAppState();
}

class _RaphaelAppState extends State<RaphaelApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raphael',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 500),
      themeAnimationCurve: Curves.easeInOutCubic,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF12B886),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF12B886),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35E8AE),
          brightness: Brightness.dark,
          surface: const Color(0xFF050606),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        cardTheme: const CardThemeData(
          color: Color(0xFF0B0C0C),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF35E8AE),
          unselectedItemColor: Color(0xFF8C9693),
          backgroundColor: Colors.black,
        ),
      ),
      home: AuthGate(onThemeChanged: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
