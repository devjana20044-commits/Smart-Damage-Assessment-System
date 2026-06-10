import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Global error logger instance for access from any service
ErrorLoggerService? globalErrorLogger;

/// Service for logging errors to a file on the device.
/// Used for crash diagnostics and fix planning.
class ErrorLoggerService {
  static ErrorLoggerService? _instance;
  late File _logFile;
  static const int _maxLogSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const String _logFileName = 'app_errors.log';

  ErrorLoggerService._();

  /// Get singleton instance
  static Future<ErrorLoggerService> getInstance() async {
    if (_instance == null) {
      _instance = ErrorLoggerService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$_logFileName');

    // Rotate log if too large
    if (await _logFile.exists()) {
      final length = await _logFile.length();
      if (length > _maxLogSizeBytes) {
        await _rotateLog();
      }
    }
  }

  /// Rotate the log file: rename current to .old, start fresh
  Future<void> _rotateLog() async {
    final oldFile = File('${_logFile.path}.old');
    if (await oldFile.exists()) {
      await oldFile.delete();
    }
    await _logFile.rename(oldFile.path);
  }

  /// Log an error with full details
  Future<void> logError({
    required String source,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final entry = <String, dynamic>{
        'timestamp': timestamp,
        'source': source,
        'error': error.toString(),
        'type': error.runtimeType.toString(),
        'stackTrace': stackTrace?.toString(),
        'extra': extra,
      };

      final line = '${jsonEncode(entry)}\n';
      await _logFile.writeAsString(line, mode: FileMode.append);

      if (kDebugMode) {
        debugPrint('📝 ERROR LOGGED [$source]: ${error.toString()}');
      }
    } catch (e) {
      // If logging itself fails, fall back to console
      debugPrint('❌ ERROR LOGGER FAILED: $e');
      debugPrint('Original error: $error');
    }
  }

  /// Log an unhandled Flutter error
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    await logError(
      source: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
      extra: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
      },
    );
  }

  /// Log a Dio/HTTP error
  Future<void> logDioError({
    required String method,
    required String url,
    required dynamic error,
    int? statusCode,
    dynamic responseBody,
    StackTrace? stackTrace,
  }) async {
    await logError(
      source: 'Dio-HTTP',
      error: error,
      stackTrace: stackTrace,
      extra: {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'responseBody': responseBody?.toString(),
      },
    );
  }

  /// Read all logged errors
  Future<List<Map<String, dynamic>>> getErrors() async {
    if (!await _logFile.exists()) return [];

    try {
      final contents = await _logFile.readAsString();
      final lines = contents.split('\n').where((l) => l.isNotEmpty);
      return lines.map((line) {
        try {
          return jsonDecode(line) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{'raw': line};
        }
      }).toList();
    } catch (e) {
      debugPrint('Error reading log file: $e');
      return [];
    }
  }

  /// Get the log file path for export
  String get logFilePath => _logFile.path;

  /// Get log file size in bytes
  Future<int> getLogFileSize() async {
    if (!await _logFile.exists()) return 0;
    return _logFile.length();
  }

  /// Clear all logged errors
  Future<void> clearLogs() async {
    if (await _logFile.exists()) {
      await _logFile.delete();
    }
  }

  /// Get count of logged errors
  Future<int> getErrorCount() async {
    final errors = await getErrors();
    return errors.length;
  }

  /// Export logs as a formatted string (for sharing)
  Future<String> exportLogs() async {
    if (!await _logFile.exists()) return 'No errors logged.';

    try {
      final contents = await _logFile.readAsString();
      final buffer = StringBuffer();
      buffer.writeln('=== Smart Damage Assessment - Error Log ===');
      buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
      buffer.writeln('---');
      buffer.write(contents);
      return buffer.toString();
    } catch (e) {
      return 'Failed to export logs: $e';
    }
  }

  /// Reset singleton (for testing)
  static void resetInstance() {
    _instance = null;
  }
}
