import 'dart:async';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final _authStateController = StreamController<User?>.broadcast();

  Stream<User?> get authStateStream => _authStateController.stream;

  AuthRepository() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final user = await getCurrentUser();
      _authStateController.add(user);
    } catch (e) {
      _authStateController.add(null);
    }
  }

  Future<User?> getCurrentUser() async {
    final accessToken = await _storageService.getAccessToken();
    if (accessToken == null) {
      _authStateController.add(null);
      return null;
    }
    // Note: In production, you should implement a /auth/me endpoint
    // to fetch the current user. For now, we check if token exists.
    // The token validation will happen on the backend.
    try {
      // You can decode JWT here or call /auth/me endpoint
      // For now, return null and let the app handle auth state via token
      return null;
    } catch (e) {
      _authStateController.add(null);
      return null;
    }
  }

  Future<User> register(String email, String password, String name) async {
    try {
      final result = await _apiService.register(email, password, name);
      final user = result['user'] as User;
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final result = await _apiService.login(email, password);
      final user = result['user'] as User;
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      _authStateController.add(null);
    } catch (e) {
      await _storageService.clearTokens();
      _authStateController.add(null);
      rethrow;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
