import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';
import '../models/user.dart';

/// Service for managing local storage using SharedPreferences
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  /// Private constructor for singleton
  StorageService._();

  /// Get singleton instance
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    print('💾 STORAGE SERVICE - Saving token: ${token.substring(0, 10)}...');
    await _prefs?.setString(AppConfig.tokenKey, token);
    final savedToken = _prefs?.getString(AppConfig.tokenKey);
    print('💾 STORAGE SERVICE - Token saved successfully: ${savedToken != null ? "YES" : "NO"}');
  }

  /// Get authentication token
  String? getToken() {
    return _prefs?.getString(AppConfig.tokenKey);
  }

  /// Remove authentication token
  Future<void> removeToken() async {
    await _prefs?.remove(AppConfig.tokenKey);
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(AppConfig.userKey, userJson);
  }

  /// Get user data
  User? getUser() {
    final userJson = _prefs?.getString(AppConfig.userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // If parsing fails, remove corrupted data
      removeUser();
      return null;
    }
  }

  /// Remove user data
  Future<void> removeUser() async {
    await _prefs?.remove(AppConfig.userKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final token = getToken();
    final user = getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  /// Get all stored keys (for debugging)
  Set<String>? getKeys() {
    return _prefs?.getKeys();
  }

  // Backend Configuration Methods

  /// Save backend IP address
  Future<void> saveBackendIP(String ip) async {
    await _prefs?.setString('backend_ip', ip);
  }

  /// Get backend IP address
  String? getBackendIP() {
    return _prefs?.getString('backend_ip');
  }

  /// Save backend port
  Future<void> saveBackendPort(String port) async {
    await _prefs?.setString('backend_port', port);
  }

  /// Get backend port
  String? getBackendPort() {
    return _prefs?.getString('backend_port');
  }

  /// Save backend path
  Future<void> saveBackendPath(String path) async {
    await _prefs?.setString('backend_path', path);
  }

  /// Get backend path
  String? getBackendPath() {
    return _prefs?.getString('backend_path');
  }

  /// Save complete backend configuration
  Future<void> saveBackendConfig({
    required String ip,
    required String port,
    required String path,
  }) async {
    await saveBackendIP(ip);
    await saveBackendPort(port);
    await saveBackendPath(path);
  }

  /// Get complete backend configuration
  Map<String, String?> getBackendConfig() {
    return {
      'ip': getBackendIP(),
      'port': getBackendPort(),
      'path': getBackendPath(),
    };
  }
}