import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/features/auth/domain/auth_state.dart';
import 'package:draw_hub/features/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/models/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier, управляющий состоянием авторизации (новый API Riverpod)
class AuthNotifier extends Notifier<AuthState> {
  late final AuthUseCase _authUseCase = ref.read(authUseCaseProvider);
  late final FirebaseAuth _firebaseAuth = ref.read(firebaseAuthProvider);

  /// Начальная инициализация состояния
  @override
  AuthState build() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return AuthStateAuthenticated(UserModel.fromFirebaseUser(currentUser));
    }
    return const AuthStateUnauthenticated();
  }

  /// Логин по email и паролю
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final user = await _authUseCase.loginUseCase(email: email, password: password);
      if (user != null) {
        state = AuthStateAuthenticated(UserModel.fromFirebaseUser(user));
      } else {
        state = const AuthStateError('Не удалось войти. Проверьте данные.');
      }
    } catch (e, stack) {
      debugPrint('AuthNotifier.login error: $e, $stack');
      state = const AuthStateError('Произошла ошибка при входе');
    }
  }

  /// Регистрация по email и паролю
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final user = await _authUseCase.registrationUseCase(
        email: email,
        password: password,
      );
      if (user != null) {
        state = AuthStateAuthenticated(UserModel.fromFirebaseUser(user));
      } else {
        state = const AuthStateError('Не удалось зарегистрироваться');
      }
    } catch (e, stack) {
      debugPrint('AuthNotifier.register error: $e, $stack');
      state = const AuthStateError('Произошла ошибка при регистрации');
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    state = const AuthStateLoading();
    try {
      await _authUseCase.logoutUseCase();
      state = const AuthStateUnauthenticated();
    } catch (e, stack) {
      debugPrint('AuthNotifier.logout error: $e, $stack');
      state = const AuthStateError('Не удалось выйти из аккаунта');
    }
  }
}

/// Провайдер для AuthNotifier на основе нового NotifierProvider API
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
