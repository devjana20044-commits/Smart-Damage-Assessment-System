import '../services/storage_service.dart';

/// Configuration class for the Smart Damage Assessment app
/// Handles different API base URLs for various development scenarios
class AppConfig {
  // Development scenarios (fallback defaults)
  static const String _androidEmulator = 'http://10.0.2.2:8000/api';
  static const String _physicalDevice = 'http://192.168.1.100:8000/api'; // Update this IP as needed
  static const String _iosSimulator = 'http://127.0.0.1:8000/api';

  /// Get the appropriate base URL based on the development scenario
  /// Default is Android Emulator. Update this constant for your setup.
  static String get baseUrl {
    // TODO: Implement platform detection or manual override
    // For now, defaulting to Android Emulator
    return _androidEmulator;
  }

  /// Build base URL dynamically from stored configuration
  /// Returns the custom URL if configured, otherwise returns the default
  static Future<String> getDynamicBaseUrl({
    String? ip,
    String? port,
    String? path,
  }) async {
    // If custom values are provided, use them directly
    if (ip != null && port != null && path != null) {
      return 'http://$ip:$port$path';
    }

    // Otherwise, try to get from SharedPreferences
    try {
      final storage = await StorageService.getInstance();
      final config = storage.getBackendConfig();

      final storedIp = config['ip'];
      final storedPort = config['port'];
      final storedPath = config['path'];

      // If all values are stored, build the URL
      if (storedIp != null && storedPort != null && storedPath != null) {
        return 'http://$storedIp:$storedPort$storedPath';
      }
    } catch (e) {
      // If there's an error reading from storage, fall back to default
    }

    // Fall back to default URL
    return baseUrl;
  }

  /// Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// App configuration
  static const String appName = 'Smart Damage Assessment';
  static const String appVersion = '1.0.0';

  /// Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  /// API response keys
  static const String successKey = 'success';
  static const String dataKey = 'data';
  static const String messageKey = 'message';
  static const String errorsKey = 'errors';
}