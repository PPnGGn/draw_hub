import 'package:draw_hub/features/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/features/auth/models/auth_user.dart';
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

// ЕДИНСТВЕННЫЙ источник истины для auth state
// Автоматически обновляется при любых изменениях в Firebase
final authUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map(
    (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
  );
});
