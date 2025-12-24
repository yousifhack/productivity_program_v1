import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

/// Compatibility for older code paths that still reference UserRole.
/// Your Firestore user doc role string is still the real source of truth.
enum UserRole { manager, employee }

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Compatibility for older code that calls watchUser()
  Stream<User?> watchUser() => _auth.authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
