import 'package:draw_hub/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//  доступ к FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Провайдер для AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Провайдер для AuthUseCase
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthUseCase(authService);
});

//  отслеживание состояния авторизации
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});
