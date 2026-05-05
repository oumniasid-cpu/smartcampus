import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("✅ Firebase Success: ${credential.user?.email} is logged in.");
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Firebase Error: ${e.code}");
      rethrow; 
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}