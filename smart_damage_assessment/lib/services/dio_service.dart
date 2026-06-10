import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';
import '../core/api_constants.dart';
import 'error_logger_service.dart';
import 'storage_service.dart';

class DioService {
  static DioService? _instance;
  late Dio _dio;
  late StorageService _storageService;

  DioService._();

  static Future<DioService> getInstance() async {
    if (_instance == null) {
      _instance = DioService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _storageService = await StorageService.getInstance();

    final baseUrl = await AppConfig.getDynamicBaseUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {ApiConstants.contentType: ApiConstants.jsonContentType},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storageService),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<void> updateBaseUrl() async {
    final baseUrl = await AppConfig.getDynamicBaseUrl();
    _dio.options.baseUrl = baseUrl;
  }

  static void resetInstance() {
    _instance = null;
  }

  Dio get dio => _dio;

  Future<void> updateAuthToken(String? token) async {
    if (token != null) {
      _dio.options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    } else {
      _dio.options.headers.remove(ApiConstants.authorization);
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    if (!options.headers.containsKey(ApiConstants.contentType) &&
        options.data is! FormData) {
      options.headers[ApiConstants.contentType] = ApiConstants.jsonContentType;
    }

    super.onRequest(options, handler);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: ${err.type} ${err.requestOptions.uri}');
      if (err.response != null) {
        debugPrint(
          '📥 ERROR RESPONSE: ${err.response?.statusCode} ${err.response?.data}',
        );
      }
    }
    super.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.connectionError:
        errorMessage =
            'Connection error. Please check your internet connection and make sure the server is running.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;

        if (statusCode == 401) {
          errorMessage =
              _extractErrorMessage(responseData) ??
              'Invalid credentials. Please check your email and password.';
        } else if (statusCode == 403) {
          errorMessage = 'Access forbidden.';
        } else if (statusCode == 404) {
          errorMessage = 'Resource not found.';
        } else if (statusCode == 422) {
          final errors = responseData?[ApiConstants.errors];
          if (errors != null && errors is Map) {
            final errorMessages = errors.values
                .expand((e) => (e as List))
                .toList();
            errorMessage = errorMessages.join('\n');
          } else {
            errorMessage =
                _extractErrorMessage(responseData) ?? 'Validation error.';
          }
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage =
              _extractErrorMessage(responseData) ?? 'Unknown error occurred.';
        }
        break;

      default:
        errorMessage = 'An unexpected error occurred. Please try again.';
    }

    // Log error to file for diagnostics
    _logErrorToFile(err, errorMessage);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: errorMessage,
      ),
    );
  }

  /// Persist error details to the error logger file
  void _logErrorToFile(DioException err, String message) {
    try {
      // Access global logger set in main.dart
      final logger = globalErrorLogger;
      if (logger != null) {
        logger.logDioError(
          method: err.requestOptions.method,
          url: err.requestOptions.uri.toString(),
          error: message,
          statusCode: err.response?.statusCode,
          responseBody: err.response?.data,
          stackTrace: err.stackTrace,
        );
      }
    } catch (_) {
      // Silent - logging failure shouldn't break the app
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;

    if (responseData['error'] != null) {
      return responseData['error'].toString();
    }
    if (responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return null;
  }
}
