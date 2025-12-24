import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/features/auth/usecases/auth_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class AuthOperationState {
  const AuthOperationState();
}

class AuthOperationIdle extends AuthOperationState {
  const AuthOperationIdle();
}

class AuthOperationLoading extends AuthOperationState {
  const AuthOperationLoading();
}

class AuthOperationSuccess extends AuthOperationState {
  const AuthOperationSuccess();
}

class AuthOperationError extends AuthOperationState {
  final String message;
  const AuthOperationError(this.message);
}

class AuthController extends Notifier<AuthOperationState> {
  late final AuthUseCase _authUseCase = ref.read(authUseCaseProvider);

  @override
  AuthOperationState build() {
    return const AuthOperationIdle();
  }

  /// Логин по email и паролю
  Future<void> login({required String email, required String password}) async {
    state = const AuthOperationLoading();
    try {
      final user = await _authUseCase.loginUseCase(
        email: email,
        password: password,
      );
      if (user != null) {
        state = const AuthOperationSuccess();
      } else {
        state = const AuthOperationError('Не удалось войти. Проверьте данные.');
      }
    } catch (e) {
      state = const AuthOperationError('Произошла ошибка при входе');
    }
  }

  /// Регистрация по email и паролю
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthOperationLoading();
    try {
      final user = await _authUseCase.registrationUseCase(
        email: email,
        password: password,
      );
      if (user != null) {
        state = const AuthOperationSuccess();
      } else {
        state = const AuthOperationError('Не удалось зарегистрироваться');
      }
    } catch (e) {
      state = const AuthOperationError('Произошла ошибка при регистрации');
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    state = const AuthOperationLoading();
    try {
      await _authUseCase.logoutUseCase();
      state = const AuthOperationSuccess();
    } catch (e) {
      state = const AuthOperationError('Не удалось выйти из аккаунта');
    }
  }

  /// Сброс состояния в idle (для очистки ошибок)
  void reset() {
    state = const AuthOperationIdle();
  }
}

/// Провайдер для AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AuthOperationState>(AuthController.new);
