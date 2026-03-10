import 'dart:async';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _authStateController = StreamController<User?>.broadcast();

  Stream<User?> get authStateStream {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        _authStateController.add(User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        ));
      } else {
        _authStateController.add(null);
      }
    });
    return _authStateController.stream;
  }

  AuthRepository() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _authStateController.add(User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
      ));
    } else {
      _authStateController.add(null);
    }
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      _authStateController.add(null);
      return null;
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
    );
  }

  Future<User> register(String email, String password, String name) async {
    try {
      final user = await _authService.signUpWithEmail(email, password, name);
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<User> signInAnonymously() async {
    try {
      final user = await _authService.signInAnonymously();
      _authStateController.add(user);
      return user;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      _authStateController.add(null);
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
