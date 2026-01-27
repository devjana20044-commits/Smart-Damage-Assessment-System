import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/dio_service.dart';
import '../services/storage_service.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  final DioService _dioService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService, this._storageService, this._dioService);

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Initialize provider and check existing authentication
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = _authService.getCurrentUser();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    print('🔐 AUTH PROVIDER - Login started for: $email');
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.login(email, password);
      print('✅ AUTH PROVIDER - Login successful, user: ${_user?.email}');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ AUTH PROVIDER - Login failed: ${e.toString()}');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      _setError('Authentication check failed: ${e.toString()}');
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}