// lib/services/local_auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static bool _useLocalStorage = true;

  static void disableLocalStorageForTest() {
    _useLocalStorage = false;
  }

  static void enableLocalStorage() {
    _useLocalStorage = true;
  }

  static Future<void> setLoggedIn(bool value) async {
    if (!_useLocalStorage) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    if (!_useLocalStorage) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setFirstTime(bool value) async {
    if (!_useLocalStorage) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, value);
  }

  static Future<bool> isFirstTime() async {
    if (!_useLocalStorage) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  static Future<void> logout() async {
    if (!_useLocalStorage) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
