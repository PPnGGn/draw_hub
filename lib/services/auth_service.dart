import 'package:draw_hub/core/errors/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('unknown', 'Не удалось создать пользователя');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    }
  }

  Future<User> loginViaEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('unknown', 'Не удалось войти');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'Unknown Firebase error');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'Не удалось выйти');
    }
  }
}
