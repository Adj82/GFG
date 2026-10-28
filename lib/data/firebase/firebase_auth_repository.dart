import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;

import '../repositories/repository.dart';

/// Firebase Auth with Google as the only way in, limited to one email domain.
///
/// The domain is enforced three times: Google is asked to show only that
/// domain (`hostedDomain` / `hd`), this class rejects any other address and
/// signs out again, and the Firestore rules refuse anyone whose verified token
/// email is outside the domain.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  String? _initialisedFor;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentEmail => _auth.currentUser?.email?.toLowerCase();

  @override
  Stream<String?> watchUserId() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<GoogleIdentity> signInWithGoogle({
    required String allowedDomain,
    String? simulatedEmail,
  }) async {
    final UserCredential cred;
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({
            'hd': allowedDomain,
            'prompt': 'select_account',
          });
        cred = await _auth.signInWithPopup(provider);
      } else {
        if (_initialisedFor != allowedDomain) {
          await GoogleSignIn.instance.initialize(hostedDomain: allowedDomain);
          _initialisedFor = allowedDomain;
        }
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw const AuthFailure('Google did not return a sign-in token.');
        }
        cred = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }
    } on GoogleSignInException {
      throw const AuthFailure('Sign-in was cancelled.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        throw const AuthFailure('Sign-in was cancelled.');
      }
      throw AuthFailure(e.message ?? 'Could not sign in with Google.');
    }

    final user = cred.user;
    final email = user?.email?.toLowerCase() ?? '';
    if (user == null ||
        !user.emailVerified ||
        !email.endsWith('@$allowedDomain')) {
      await signOut();
      throw AuthFailure('Use your @$allowedDomain Google account.');
    }
    return GoogleIdentity(
      uid: user.uid,
      email: email,
      name: user.displayName ?? email.split('@').first,
    );
  }

  // Password sign-in exists only for the on-device demo. In Firebase mode the
  // sign-in screen offers Google alone.
  @override
  Future<String> signIn({required String email, required String password}) =>
      throw const AuthFailure('Sign in with Google.');

  @override
  Future<String> signUp({required String email, required String password}) =>
      throw const AuthFailure('Sign in with Google.');

  @override
  Future<void> changePassword({required String newPassword}) =>
      throw const AuthFailure('Accounts use Google; there is no password.');

  @override
  Future<void> requestPasswordReset({required String email}) =>
      throw const AuthFailure('Accounts use Google; there is no password.');

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Not signed in through the native flow (web, or already out).
    }
    await _auth.signOut();
  }
}
