import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String autoFetchingKey = 'autoFetching';
  static const String fetchIntervalKey = 'fetchInterval';
  static const String notificationsEnabledKey = 'notificationsEnabled';
  static const String fetchOnStartupKey = 'fetchOnStartup';

  bool? _autoFetchingEnabled;
  int? _fetchInterval;
  bool? _notificationsEnabled;
  bool? _fetchOnStartup;

  Future init() async {
    await _loadSettings();
  }

  SettingsProvider() {
    _loadSettings();
  }

  bool get fetchOnStartup {
    return _fetchOnStartup ?? true;
  }

  set fetchOnStartup(bool value) {
    _fetchOnStartup = value;
    _savesetting(fetchOnStartupKey, value);
    notifyListeners();
  }

  bool get autoFetchingEnabled {
    return _autoFetchingEnabled ?? true;
  }

  set autoFetchingEnabled(bool value) {
    _autoFetchingEnabled = value;
    _savesetting(autoFetchingKey, value);
    notifyListeners();
  }

  int get fetchInterval {
    return _fetchInterval ?? 15;
  }

  set fetchInterval(int value) {
    _fetchInterval = value;
    _savesetting(fetchIntervalKey, value);
    notifyListeners();
  }

  bool get notificationsEnabled {
    return _notificationsEnabled ?? true;
  }

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _savesetting(notificationsEnabledKey, value);
    notifyListeners();
  }

  Future _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? fetchInterval = prefs.getInt(fetchIntervalKey);
    bool? autofetching = prefs.getBool(autoFetchingKey);
    bool? notifications = prefs.getBool(notificationsEnabledKey);
    bool? fetchonstartup = prefs.getBool(fetchOnStartupKey);
    _fetchInterval = fetchInterval;
    _autoFetchingEnabled = autofetching;
    _notificationsEnabled = notifications;
    _fetchOnStartup = fetchonstartup;
    notifyListeners();
  }

  _savesetting(String key, var setting) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (setting is bool) {
      prefs.setBool(key, setting);
    } else {
      prefs.setInt(key, setting);
    }
  }
}
