// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String autoFetchingKey = 'autoFetching';
  static const String fetchIntervalKey = 'fetchInterval';
  static const String notificationsEnabledKey = 'notificationsEnabled';
  static const String fetchOnStartupKey = 'fetchOnStartup';

  late SharedPreferences _prefs;

  bool _autoFetchingEnabled = true;
  int _fetchInterval = 15;
  bool _notificationsEnabled = true;
  bool _fetchOnStartup = true;

  SettingsProvider() {
    _loadSettings();
  }
  bool get fetchOnStartup => _fetchOnStartup;
  set fetchOnStartup(bool value) {
    _fetchOnStartup = value;
    _saveSettings();
    notifyListeners();
  }

  bool get autoFetchingEnabled => _autoFetchingEnabled;
  set autoFetchingEnabled(bool value) {
    _autoFetchingEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  int get fetchInterval => _fetchInterval;

  set fetchInterval(int value) {
    _fetchInterval = value;
    _saveSettings();
    notifyListeners();
  }

  bool get notificationsEnabled => _notificationsEnabled;

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _autoFetchingEnabled = _prefs.getBool(autoFetchingKey) ?? false;
    _fetchInterval = _prefs.getInt(fetchIntervalKey) ?? 15;
    _notificationsEnabled = _prefs.getBool(notificationsEnabledKey) ?? true;
    _fetchOnStartup = _prefs.getBool(fetchOnStartupKey) ?? true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool(autoFetchingKey, _autoFetchingEnabled);
    await _prefs.setInt(fetchIntervalKey, _fetchInterval);
    await _prefs.setBool(notificationsEnabledKey, _notificationsEnabled);
    await _prefs.setBool(fetchOnStartupKey, _fetchOnStartup);
  }
}
