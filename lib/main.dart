import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talon/firebase_options.dart';
import 'package:talon/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final preferences = await SharedPreferences.getInstance();

  runApp(
    TalonApp(
      darkMode: preferences.getBool('dark_mode') ?? false,
      notifications: preferences.getBool('notifications') ?? true,
      readReceipts: preferences.getBool('read_receipts') ?? true,
      profileVisibility:
          preferences.getBool('profile_visibility') ?? true,
      onlineStatus:
          preferences.getBool('online_status') ?? true,
      language:
          preferences.getString('language') ?? 'English',
    ),
  );
}

class TalonApp extends StatefulWidget {
  final bool darkMode;
  final bool notifications;
  final bool readReceipts;
  final bool profileVisibility;
  final bool onlineStatus;
  final String language;

  const TalonApp({
    super.key,
    required this.darkMode,
    required this.notifications,
    required this.readReceipts,
    required this.profileVisibility,
    required this.onlineStatus,
    required this.language,
  });

  static TalonAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<TalonAppState>();
  }

  @override
  State<TalonApp> createState() => TalonAppState();
}

class TalonAppState extends State<TalonApp> {
  late bool _darkMode;
  late bool _notifications;
  late bool _readReceipts;
  late bool _profileVisibility;
  late bool _onlineStatus;
  late String _language;

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get readReceipts => _readReceipts;
  bool get profileVisibility => _profileVisibility;
  bool get onlineStatus => _onlineStatus;
  String get language => _language;

  @override
  void initState() {
    super.initState();

    _darkMode = widget.darkMode;
    _notifications = widget.notifications;
    _readReceipts = widget.readReceipts;
    _profileVisibility = widget.profileVisibility;
    _onlineStatus = widget.onlineStatus;
    _language = widget.language;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);

    if (!mounted) return;

    setState(() {
      _darkMode = value;
    });
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);

    if (!mounted) return;

    setState(() {
      _notifications = value;
    });
  }

  Future<void> setReadReceipts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('read_receipts', value);

    if (!mounted) return;

    setState(() {
      _readReceipts = value;
    });
  }

  Future<void> setProfileVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'profile_visibility',
      value,
    );

    if (!mounted) return;

    setState(() {
      _profileVisibility = value;
    });
  }

  Future<void> setOnlineStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'online_status',
      value,
    );

    if (!mounted) return;

    setState(() {
      _onlineStatus = value;
    });
  }

  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'language',
      value,
    );

    if (!mounted) return;

    setState(() {
      _language = value;
    });
  }

  ThemeData _buildLightTheme() {
    const green = Colors.green;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAF8),

      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.black87,
        ),
        hintStyle: const TextStyle(
          color: Colors.black54,
        ),
        prefixIconColor: green,
        suffixIconColor: green,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: Color(0xFFD0D7D0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: green,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          color: Colors.black54,
        ),
        titleLarge: TextStyle(
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          color: Colors.black87,
        ),
        titleSmall: TextStyle(
          color: Colors.black87,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const green = Colors.green;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),

      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        labelStyle: TextStyle(
          color: Colors.white70,
        ),
        hintStyle: TextStyle(
          color: Colors.white54,
        ),
        prefixIconColor: green,
        suffixIconColor: green,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: Color(0xFF444444),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: green,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          color: Colors.white70,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talon',
      debugShowCheckedModeBanner: false,

      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),

      themeMode:
          _darkMode
              ? ThemeMode.dark
              : ThemeMode.light,

      home: const SplashScreen(),
    );
  }
}
