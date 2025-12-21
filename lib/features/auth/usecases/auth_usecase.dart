import 'package:draw_hub/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUseCase {
  final AuthService _authService;

  AuthUseCase(this._authService);

  Future<User?> registrationUseCase({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.registerViaEmailPassword(
        email: email,
        password: password,
      );
      return user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}, ${e.message}');
      return null;
    }
  }

  Future<User?> loginUseCase({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.loginViaEmailPassword(
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      print('Ошибка входа: $e');
      return null;
    }
  }

  Future<void> logoutUseCase() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('не удалось выйти: $e');
    }
  }
}
