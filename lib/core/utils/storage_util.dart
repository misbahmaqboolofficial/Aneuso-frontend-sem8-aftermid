import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageUtil {
  static final StorageUtil _instance = StorageUtil._internal();
  factory StorageUtil() => _instance;
  StorageUtil._internal();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<bool> setToken(String token) async {
    return await _prefs?.setString(AppConstants.tokenKey, token) ?? false;
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<bool> removeToken() async {
    return await _prefs?.remove(AppConstants.tokenKey) ?? false;
  }

  // User Data Management
  static Future<bool> setUserData(String userJson) async {
    return await _prefs?.setString(AppConstants.userKey, userJson) ?? false;
  }

  static String? getUserData() {
    return _prefs?.getString(AppConstants.userKey);
  }

  static Future<bool> removeUserData() async {
    return await _prefs?.remove(AppConstants.userKey) ?? false;
  }
  static Future<bool> removeAllData() async {
    return await _prefs?.clear() ?? false;
  }

  // User Data Management
  static Future<bool> setStringData(String key, String stringJson) async {
    return await _prefs?.setString(key, stringJson) ?? false;
  }

  static String? getStringData(String key ) {
    return _prefs?.getString(key);
  }

  static Future<bool> removeStringData(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeUserData();
    await removeAllData();
  }
}
