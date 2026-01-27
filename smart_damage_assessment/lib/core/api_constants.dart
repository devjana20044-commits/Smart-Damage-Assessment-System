/// API endpoint constants for the Smart Damage Assessment app
class ApiConstants {
  // Health check endpoint
  static const String health = '/';

  // Authentication endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';

  // Reports endpoints
  static const String reports = '/reports';

  // HTTP methods
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';

  // HTTP headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Content types
  static const String jsonContentType = 'application/json';
  static const String multipartContentType = 'multipart/form-data';

  // Form field names for report creation (updated to match new API)
  static const String rawLocation = 'raw_location';
  static const String rawDescription = 'raw_description';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String image = 'image';

  // Legacy field names (kept for backward compatibility)
  static const String userInputLocation = 'raw_location';
  static const String userNotes = 'raw_description';

  // Response field names
  static const String success = 'success';
  static const String data = 'data';
  static const String message = 'message';
  static const String errors = 'errors';
  static const String token = 'token';
  static const String user = 'user';
  static const String status = 'status';
  static const String version = 'version';
  static const String timestamp = 'timestamp';
  static const String error = 'error';
}