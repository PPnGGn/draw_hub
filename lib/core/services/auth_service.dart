import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/core/errors/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> registerViaEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('unknown', 'Не удалось создать пользователя');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload(); // Обновляем данные
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'displayName': displayName ?? 'Без имени',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
