import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_constants.dart';
import '../models/user.dart';
import 'dio_service.dart';
import 'storage_service.dart';

class AuthService {
  final DioService _dioService;
  final StorageService _storageService;

  AuthService(this._dioService, this._storageService);

  Future<User> login(String email, String password) async {
    try {
      final response = await _dioService.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final token = responseData[ApiConstants.token] as String?;
        final userData =
            responseData[ApiConstants.user] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          debugPrint('✅ Login successful');

          final user = User.fromJson(userData);

          await _storageService.saveToken(token);
          await _storageService.saveUser(user);
          await _dioService.updateAuthToken(token);

          return user;
        } else {
          throw Exception('Invalid response: token or user data is missing');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Login failed. Please try again.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

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

      if (responseData is Map<String, dynamic>) {
        final token = responseData[ApiConstants.token] as String?;
        final userData =
            responseData[ApiConstants.user] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          debugPrint('✅ Register successful');

          final user = User.fromJson(userData);

          await _storageService.saveToken(token);
          await _storageService.saveUser(user);
          await _dioService.updateAuthToken(token);

          return user;
        } else {
          throw Exception('Invalid response: token or user data is missing');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Registration failed. Please try again.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _dioService.dio.post(ApiConstants.logout);
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    } finally {
      await _storageService.removeToken();
      await _storageService.removeUser();
      await _dioService.updateAuthToken(null);
    }
  }

  Future<bool> isAuthenticated() async {
    final token = _storageService.getToken();
    final user = _storageService.getUser();

    if (token == null || user == null) {
      return false;
    }

    await _dioService.updateAuthToken(token);

    return true;
  }

  User? getCurrentUser() {
    return _storageService.getUser();
  }

  String? getCurrentToken() {
    return _storageService.getToken();
  }

  Future<User> fetchCurrentUser() async {
    try {
      final response = await _dioService.dio.get(ApiConstants.me);

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final user = User.fromJson(responseData);
        await _storageService.saveUser(user);
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Failed to fetch user data.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch current user: ${e.toString()}');
    }
  }

  Future<User> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
    File? profileImage,
  }) async {
    try {
      if (profileImage != null) {
        final formDataMap = <String, dynamic>{
          '_method': 'PUT',
          'name': name,
          'email': email,
        };
        if (currentPassword != null && currentPassword.isNotEmpty) {
          formDataMap['current_password'] = currentPassword;
        }
        if (newPassword != null && newPassword.isNotEmpty) {
          formDataMap['password'] = newPassword;
          formDataMap['password_confirmation'] = newPasswordConfirmation ?? '';
        }
        formDataMap['profile_image'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        );
        final formData = FormData.fromMap(formDataMap);
        final response = await _dioService.dio.post(
          ApiConstants.me,
          data: formData,
        );
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final userData =
              responseData['user'] as Map<String, dynamic>? ?? responseData;
          final user = User.fromJson(userData);
          await _storageService.saveUser(user);
          return user;
        } else {
          throw Exception('Invalid response format');
        }
      }

      final data = <String, dynamic>{'name': name, 'email': email};
      if (currentPassword != null && currentPassword.isNotEmpty) {
        data['current_password'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        data['password'] = newPassword;
        data['password_confirmation'] = newPasswordConfirmation ?? '';
      }

      final response = await _dioService.dio.put(ApiConstants.me, data: data);

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final userData =
            responseData['user'] as Map<String, dynamic>? ?? responseData;
        final user = User.fromJson(userData);
        await _storageService.saveUser(user);
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.error is String
          ? e.error as String
          : 'Failed to update profile.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
