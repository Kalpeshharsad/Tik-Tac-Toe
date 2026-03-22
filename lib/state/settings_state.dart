import 'package:flutter/material.dart';

class SettingsState extends ChangeNotifier {
  bool _soundFxEnabled = true;
  bool _hapticsEnabled = true;
  bool _isDarkMode = true;
  Color _accentColor = const Color(0xFF81ECFF); // Default Cyan
  String _selectedAccentLabel = 'Cyan';
  String _userName = 'Alex Vance';
  String _userRank = 'Grandmaster • Rank #142';

  // Getters
  bool get soundFxEnabled => _soundFxEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  String get selectedAccentLabel => _selectedAccentLabel;
  String get userName => _userName;
  String get userRank => _userRank;

  // Setters & Actions
  void toggleSoundFx(bool value) {
    _soundFxEnabled = value;
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _hapticsEnabled = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void updateAccentColor(Color color, String label) {
    _accentColor = color;
    _selectedAccentLabel = label;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void logout() {
    // Implement logout logic (e.g., clear tokens, reset state)
    _userName = 'Guest';
    _userRank = 'Newbie • Rank #0';
    notifyListeners();
  }
}
