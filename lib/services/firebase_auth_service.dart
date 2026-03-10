import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService {
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  FirebaseAuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      // Firebase not initialized - will handle gracefully
      _auth = null;
    }
  }
  
  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase is not initialized. Please configure Firebase first.');
    }
    return _auth!;
  }

  Stream<User?> get authStateChanges {
    if (_auth == null) return Stream.value(null);
    return _auth!.authStateChanges();
  }

  User? get currentUser => _auth?.currentUser;

  Future<app_user.User> signUpWithEmail(String email, String password, String name) async {
    if (_auth == null) {
      throw Exception('Firebase is not initialized');
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        final updatedUser = _auth!.currentUser;
        
        return app_user.User(
          id: updatedUser!.uid,
          email: updatedUser.email!,
          name: updatedUser.displayName ?? name,
        );
      }
      throw Exception('Failed to create user');
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<app_user.User> signInWithEmail(String email, String password) async {
    if (_auth == null) {
      throw Exception('Firebase is not initialized');
    }
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = credential.user!;
        return app_user.User(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? user.email!.split('@')[0],
        );
      }
      throw Exception('Failed to sign in');
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<app_user.User> signInWithGoogle() async {
    if (_auth == null) {
      throw Exception('Firebase is not initialized');
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);
      if (userCredential.user != null) {
        final user = userCredential.user!;
        return app_user.User(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? user.email!.split('@')[0],
        );
      }
      throw Exception('Failed to sign in with Google');
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  Future<app_user.User> signInAnonymously() async {
    if (_auth == null) {
      throw Exception('Firebase is not initialized');
    }
    try {
      final credential = await _auth!.signInAnonymously();
      if (credential.user != null) {
        final user = credential.user!;
        return app_user.User(
          id: user.uid,
          email: 'guest@anonymous.com',
          name: 'Guest User',
        );
      }
      throw Exception('Failed to sign in anonymously');
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await Future.wait([
        _auth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    } else {
      await _googleSignIn.signOut();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: $code';
    }
  }
}
