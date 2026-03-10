import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateStream;
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
});

final googleSignInProvider = FutureProvider.family<User, void>((ref, _) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.signInWithGoogle();
});
