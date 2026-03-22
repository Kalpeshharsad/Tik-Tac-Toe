import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends ChangeNotifier {
  bool _soundFxEnabled = true;
  bool _hapticsEnabled = true;
  bool _isDarkMode = true;
  Color _accentColor = const Color(0xFF81ECFF); // Default Cyan
  String _selectedAccentLabel = 'Cyan';
  String _userName = 'Alex Vance';
  String _userRank = 'Grandmaster • Rank #142';

  SettingsState() {
    _loadSettings();
  }

  // Getters
  bool get soundFxEnabled => _soundFxEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  String get selectedAccentLabel => _selectedAccentLabel;
  String get userName => _userName;
  String get userRank => _userRank;

  // Persistence Keys
  static const String _keySound = 'sound_fx';
  static const String _keyHaptics = 'haptics';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyAccentColor = 'accent_color';
  static const String _keyAccentLabel = 'accent_label';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRank = 'user_rank';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundFxEnabled = prefs.getBool(_keySound) ?? true;
    _hapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? true;
    final colorValue = prefs.getInt(_keyAccentColor);
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    _selectedAccentLabel = prefs.getString(_keyAccentLabel) ?? 'Cyan';
    _userName = prefs.getString(_keyUserName) ?? 'Alex Vance';
    _userRank = prefs.getString(_keyUserRank) ?? 'Grandmaster • Rank #142';
    notifyListeners();
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // Setters & Actions
  void toggleSoundFx(bool value) {
    _soundFxEnabled = value;
    _saveBool(_keySound, value);
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _hapticsEnabled = value;
    _saveBool(_keyHaptics, value);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveBool(_keyDarkMode, value);
    notifyListeners();
  }

  void updateAccentColor(Color color, String label) {
    _accentColor = color;
    _selectedAccentLabel = label;
    _saveInt(_keyAccentColor, color.value);
    _saveString(_keyAccentLabel, label);
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    _saveString(_keyUserName, name);
    notifyListeners();
  }

  void logout() {
    _userName = 'Guest';
    _userRank = 'Newbie • Rank #0';
    _saveString(_keyUserName, _userName);
    _saveString(_keyUserRank, _userRank);
    notifyListeners();
  }
}
