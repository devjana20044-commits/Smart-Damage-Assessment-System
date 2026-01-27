import 'package:dio/dio.dart';
import '../core/config.dart';
import '../core/api_constants.dart';
import 'storage_service.dart';

/// Service for configuring and managing Dio HTTP client
class DioService {
  static DioService? _instance;
  late Dio _dio;
  late StorageService _storageService;

  /// Private constructor for singleton
  DioService._();

  /// Get singleton instance
  static Future<DioService> getInstance() async {
    if (_instance == null) {
      _instance = DioService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize Dio with configuration
  Future<void> _init() async {
    _storageService = await StorageService.getInstance();

    // Get dynamic base URL from stored settings
    final baseUrl = await AppConfig.getDynamicBaseUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          ApiConstants.contentType: ApiConstants.jsonContentType,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(_storageService),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  /// Update base URL from stored settings
  Future<void> updateBaseUrl() async {
    final baseUrl = await AppConfig.getDynamicBaseUrl();
    _dio.options.baseUrl = baseUrl;
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// Update auth token in headers
  Future<void> updateAuthToken(String? token) async {
    if (token != null) {
      _dio.options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
    } else {
      _dio.options.headers.remove(ApiConstants.authorization);
    }
  }
}

/// Interceptor for adding authentication token to requests
class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token if available
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
    }

    // Ensure content-type is set for non-multipart requests
    if (!options.headers.containsKey(ApiConstants.contentType) &&
        options.data is! FormData) {
      options.headers[ApiConstants.contentType] = ApiConstants.jsonContentType;
    }

    super.onRequest(options, handler);
  }
}

/// Interceptor for logging requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST: ${options.method} ${options.uri}');
    if (options.data != null) {
      print('📤 DATA: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('📥 RESPONSE DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.type} ${err.requestOptions.uri}');
    if (err.response != null) {
      print('📥 ERROR RESPONSE: ${err.response?.statusCode} ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

/// Interceptor for handling common errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common HTTP errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout. Please check your internet connection.');

      case DioExceptionType.connectionError:
        throw Exception('Connection error. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;

        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden.');
        } else if (statusCode == 404) {
          throw Exception('Resource not found.');
        } else if (statusCode == 422) {
          // Validation errors
          final errors = responseData?[ApiConstants.errors];
          if (errors != null && errors is Map) {
            final errorMessages = errors.values.expand((e) => e).toList();
            throw Exception(errorMessages.join('\n'));
          }
          throw Exception('Validation error.');
        } else if (statusCode == 500) {
          throw Exception('Server error. Please try again later.');
        } else {
          throw Exception('HTTP ${statusCode}: ${responseData?[ApiConstants.message] ?? 'Unknown error'}');
        }

      default:
        throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}