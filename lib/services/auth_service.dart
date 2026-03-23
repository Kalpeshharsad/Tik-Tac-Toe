import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _currentUserId != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('auth_user_id');
    notifyListeners();
  }

  Future<bool> login(String userId, String password) async {
    // Mock login: Accept any login, save ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_id', userId);
    _currentUserId = userId;
    notifyListeners();
    return true;
  }

  Future<bool> register(String userId, String password) async {
    // Mock register
    return await login(userId, password);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user_id');
    _currentUserId = null;
    notifyListeners();
  }
}
