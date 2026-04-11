import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import '../models/user.dart';
import 'dio_service.dart';
import 'storage_service.dart';

/// Service for handling authentication API calls
class AuthService {
  final DioService _dioService;
  final StorageService _storageService;

  AuthService(this._dioService, this._storageService);

  /// Login user with email and password
  Future<User> login(String email, String password) async {
    try {
      final response = await _dioService.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;
      print(
        '🔍 AUTH SERVICE - Response data type: ${responseData.runtimeType}',
      );
      print('🔍 AUTH SERVICE - Response data: $responseData');

      // Handle the actual API response structure
      // API returns: { "token": "...", "user": {...} }
      if (responseData is Map<String, dynamic>) {
        final token = responseData[ApiConstants.token] as String?;
        final userData =
            responseData[ApiConstants.user] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          print('✅ Token extracted: $token');
          print('✅ User data: $userData');

          final user = User.fromJson(userData);

          // Save token and user data
          await _storageService.saveToken(token);
          await _storageService.saveUser(user);

          // Update Dio headers with token
          await _dioService.updateAuthToken(token);

          print('✅ Login successful, user saved');
          return user;
        } else {
          print('❌ Login failed - token or user data is null');
          throw Exception('Invalid response: token or user data is missing');
        }
      } else {
        print('❌ Login failed - response is not a Map');
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      // Error interceptor already created user-friendly message in e.error
      final message = e.error is String
          ? e.error as String
          : 'Login failed. Please try again.';
      print('❌ Login DioException: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dioService.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final responseData = response.data;
      print('🔍 AUTH SERVICE - Register response data: $responseData');

      // Handle of actual API response structure
      // API returns: { "token": "...", "user": {...} }
      if (responseData is Map<String, dynamic>) {
        final token = responseData[ApiConstants.token] as String?;
        final userData =
            responseData[ApiConstants.user] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          print('✅ Register - Token extracted: $token');
          print('✅ Register - User data: $userData');

          final user = User.fromJson(userData);

          // Save token and user data
          await _storageService.saveToken(token);
          await _storageService.saveUser(user);

          // Update Dio headers with token
          await _dioService.updateAuthToken(token);

          print('✅ Register successful, user saved');
          return user;
        } else {
          print('❌ Register failed - token or user data is null');
          throw Exception('Invalid response: token or user data is missing');
        }
      } else {
        print('❌ Register failed - response is not a Map');
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Registration failed. Please try again.';
      print('❌ Register DioException: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Register error: ${e.toString()}');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _dioService.dio.post(ApiConstants.logout);
    } catch (e) {
      // Even if logout API call fails, we should clear local data
      print('Logout API call failed: $e');
    } finally {
      // Clear local storage
      await _storageService.removeToken();
      await _storageService.removeUser();

      // Clear auth token from Dio headers
      await _dioService.updateAuthToken(null);
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final token = _storageService.getToken();
    final user = _storageService.getUser();

    if (token == null || user == null) {
      return false;
    }

    // Update Dio headers with stored token
    await _dioService.updateAuthToken(token);

    return true;
  }

  /// Get current user from storage
  User? getCurrentUser() {
    return _storageService.getUser();
  }

  /// Get current token
  String? getCurrentToken() {
    return _storageService.getToken();
  }

  /// Fetch current user from API
  Future<User> fetchCurrentUser() async {
    try {
      final response = await _dioService.dio.get(ApiConstants.me);

      final responseData = response.data;
      print('🔍 AUTH SERVICE - Current user response data: $responseData');

      if (responseData is Map<String, dynamic>) {
        final user = User.fromJson(responseData);

        // Update stored user data
        await _storageService.saveUser(user);

        print('✅ Current user fetched successfully: $user');
        return user;
      } else {
        print('❌ Failed to fetch current user - response is not a Map');
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Failed to fetch user data.';
      print('❌ Fetch current user DioException: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Fetch current user error: ${e.toString()}');
      throw Exception('Failed to fetch current user: ${e.toString()}');
    }
  }
}
