import '../services/storage_service.dart';

/// Configuration class for the Smart Damage Assessment app
/// Handles different API base URLs - editable from Settings screen
class AppConfig {
  // Default fallback values (used only when no saved config exists)
  // These are NOT const — user can change them from Settings screen
  static String defaultIp = '192.168.43.19';
  static String defaultPort = '8000';
  static String defaultPath = '/api';

  /// Build base URL from current defaults
  static String get _defaultUrl => 'http://$defaultIp:$defaultPort$defaultPath';

  /// Get the fallback base URL (used when no SharedPreferences config exists)
  static String get baseUrl => _defaultUrl;

  /// Build base URL dynamically from stored configuration
  /// Returns the custom URL from SharedPreferences if configured,
  /// otherwise returns the default
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
