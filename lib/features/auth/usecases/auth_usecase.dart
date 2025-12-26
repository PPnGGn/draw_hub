import 'package:draw_hub/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUseCase {
  final AuthService _authService;

  AuthUseCase(this._authService);

  Future<User> registrationUseCase({
    required String email,
    required String password,
  }) async {
    return await _authService.registerViaEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<User> loginUseCase({
    required String email,
    required String password,
  }) async {
    return await _authService.loginViaEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logoutUseCase() async {
    await _authService.logout();
  }
}
