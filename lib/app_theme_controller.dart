import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class AppThemeController extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _colorKey = 'accent_color';

  AppThemeMode mode = AppThemeMode.dark;
  int accentValue = 0xFF20A875;

  Color get accentColor => Color(accentValue);

  ThemeMode get themeMode => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMode = prefs.getString(_modeKey);

    mode = AppThemeMode.values.firstWhere(
      (item) => item.name == savedMode,
      orElse: () => AppThemeMode.dark,
    );

    accentValue = prefs.getInt(_colorKey) ?? 0xFF20A875;

    notifyListeners();
  }

  Future<void> setMode(AppThemeMode value) async {
    mode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, value.name);
  }

  Future<void> setAccent(int value) async {
    accentValue = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, value);
  }
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required Color accent,
}) {
  final dark = brightness == Brightness.dark;

  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: brightness,
    surface: dark ? const Color(0xFF171C1A) : const Color(0xFFFFFFFF),
  );

  final background = dark ? const Color(0xFF101412) : const Color(0xFFF4F7F5);

  final surface = dark ? const Color(0xFF171C1A) : Colors.white;

  final field = dark ? const Color(0xFF202824) : const Color(0xFFF0F4F1);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 5),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    ),

    listTileTheme: ListTileThemeData(iconColor: scheme.primary),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
    ),
  );
}
