import 'dart:math' as math;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': 'patient'},
    );
    if (role == 'caregiver') {
      // Wait for trigger to create profile row, then call RPC to upgrade
      String? uid;
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        uid = _client.auth.currentUser?.id ?? uid;
        if (uid == null) continue;
        final row = await _client.from('profiles').select('id').eq('id', uid).maybeSingle();
        if (row != null) break;
      }
      if (uid == null) throw Exception('No user after signup');
      await _client.rpc('become_caregiver');
      // Read back invite code
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final row = await _client.from('profiles').select('invite_code').eq('id', uid).maybeSingle();
        if (row != null) {
          final code = row['invite_code'] as String?;
          if (code != null && code.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('caregiver_invite_code', code);
          }
          break;
        }
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId:
          '928147229749-tqskueiqb1du9lcao4csrj3mn9409lpc.apps.googleusercontent.com',
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID token received from Google');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> logout() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _client.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  bool hasValidSession() {
    return _client.auth.currentSession != null;
  }

  // ponytail: Drift DAOs need int; hash UUID so callers compile until Supabase data layer replaces Drift.
  int? get currentUserId => _client.auth.currentUser?.id.hashCode;
  String? get currentUserUid => _client.auth.currentUser?.id;

  // ponytail: shims for pre-migration callers — role/onboarding state is in-memory only until screens are rewritten
  String? _selectedRole;
  bool _hasSeenOnboarding = false;

  String? get selectedRole => _selectedRole;
  String? get firebaseUid => currentUserUid;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> setSelectedRole(String role) async { _selectedRole = role; }
  Future<void> setHasSeenOnboarding(bool val) async { _hasSeenOnboarding = val; }
  Future<Map<String, dynamic>?> getCurrentUser() async => null;

  Future<void> deleteMyAccount() async {
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}
