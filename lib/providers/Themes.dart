import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData light = ThemeData.from(
  colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      background: Color(0xFFfdfdfd),
      onBackground: Color.fromARGB(255, 25, 24, 29),
      secondary: Color(0xFF00FFD1),
      onSecondary: Color(0xFF7e7e7e),
      primary: Color(0xFF28EECA),
      secondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color.fromARGB(255, 50, 197, 55),
      primaryContainer: Colors.white),
);

ThemeData dark = ThemeData.from(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    background: Color.fromARGB(255, 25, 24, 29),
    onBackground: Color(0xFFFFFFFF),
    secondary: Color(0xFF00FFD1),
    onSecondary: Color(0xFF7e7e7e),
    secondaryContainer: Color(0xFF444444),
    primary: Color(0xFF28EECA),
    primaryContainer: Color(0xFF3f3f3f),
    tertiary: Color.fromARGB(255, 50, 197, 55),
  ),
);

class ThemeService with ChangeNotifier {
  ThemeMode? _themeMode;
  ThemeMode defaultThemeMode = ThemeMode.system;

  Future init() async {
    await _getThemeModeFromSharedPrefs();
  }

  ThemeService() {
    _getThemeModeFromSharedPrefs();
  }

  ThemeMode get themeMode {
    return _themeMode ?? ThemeMode.light;
  }

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeModeInSharedPrefs(themeMode);
    notifyListeners();
  }

  Future _getThemeModeFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeFromPrefs = prefs.getString('themeMode');
    _themeMode = ThemeMode.values.firstWhere(
        (element) => themeModeFromPrefs == element.toString(),
        orElse: () => defaultThemeMode);
    notifyListeners();
  }

  _saveThemeModeInSharedPrefs(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', themeMode.toString());
  }
}
