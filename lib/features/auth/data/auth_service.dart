import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  factory AuthFailure.fromFirebase(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AuthFailure('Please enter a valid email address.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Invalid email or password.');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists for this email.');
      case 'weak-password':
        return const AuthFailure('Please choose a stronger password.');
      case 'operation-not-allowed':
        return const AuthFailure(
          'Email/password sign-in is disabled in Firebase. Enable it in Firebase Console > Authentication > Sign-in method.',
        );
      case 'network-request-failed':
        return const AuthFailure('Check your internet connection and try again.');
      default:
        return AuthFailure(error.message ?? 'Authentication failed. Try again.');
    }
  }
}

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _checkConfig() {
    final options = _auth.app.options;
    if (options.apiKey == 'YOUR_KEY' || options.appId == 'YOUR_APP_ID') {
      throw const AuthFailure(
        'Firebase is not fully configured. Please replace the placeholders in lib/firebase_options.dart with your actual Firebase keys.',
      );
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    
    // --- GUEST MODE FOR TESTING ---
    if (trimmedEmail == 'guest@smartcampus.com' && password == 'guest123') {
      debugPrint('👤 [AUTH] Entering Guest Mode...');
      // Note: We don't actually sign in to Firebase here to avoid config errors
      // In a real app, you'd use a mock user, but for now we'll try to let it pass
      // if Firebase is configured, otherwise we'll throw a helpful error.
    }

    _checkConfig();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw const AuthFailure('Login timed out. Please check your internet connection.');
      });
      
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Unable to sign in. Try again.');
      }

      try {
        await _ensureUserDocument(user).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('⚠️ [AUTH] Profile sync skipped/failed: $e');
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Login failed: ${e.toString().split(':').last.trim()}');
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _checkConfig();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw const AuthFailure('Registration timed out. Please check your internet connection.');
      });

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Unable to create account. Try again.');
      }

      final displayName = name.trim();
      await user.updateDisplayName(displayName);

      try {
        await _ensureUserDocument(user, displayName: displayName).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('⚠️ Profile creation failed during registration: $e');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification().catchError((e) => debugPrint('⚠️ Failed to send verification email: $e'));
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Registration failed: $e');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _ensureUserDocument(
    User user, {
    String? displayName,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    final data = snapshot.data();
    final now = FieldValue.serverTimestamp();
    final resolvedDisplayName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : (user.displayName ?? '');
    final createdAt =
        snapshot.exists && data != null ? data['createdAt'] : now;

    await ref.set({
      'uid': user.uid,
      'displayName': resolvedDisplayName,
      'email': user.email ?? '',
      'role': data == null ? 'student' : data['role'] ?? 'student',
      'photoUrl': user.photoURL,
      'badges': data == null ? <String>[] : data['badges'] ?? <String>[],
      'emailVerified': user.emailVerified,
      'createdAt': createdAt,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}
