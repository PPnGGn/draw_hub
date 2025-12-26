import 'package:draw_hub/core/errors/auth_exception.dart';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
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

  Future<void> login({required String email, required String password}) async {
    state = const AuthOperationLoading();
    try {
      await _authUseCase.loginUseCase(email: email, password: password);
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      state = AuthOperationError(e.userMessage);
    } catch (e) {
      state = const AuthOperationError('Неизвестная ошибка при входе');
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthOperationLoading();
    try {
      await _authUseCase.registrationUseCase(email: email, password: password);
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      state = AuthOperationError(e.userMessage);
    } catch (e) {
      state = const AuthOperationError('Неизвестная ошибка при регистрации');
    }
  }

  Future<void> logout() async {
    state = const AuthOperationLoading();
    try {
      await _authUseCase.logoutUseCase();
      state = const AuthOperationSuccess();
    } on AuthException catch (e) {
      state = AuthOperationError(e.userMessage);
    } catch (e) {
      state = const AuthOperationError('Не удалось выйти из аккаунта');
    }
  }
}

/// Провайдер для AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AuthOperationState>(AuthController.new);
