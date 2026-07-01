import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthState { loading, unauthenticated, authenticated }

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase);
});

/// Single source of truth for auth state — the router listens to this (fixes Bug #6).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange.map((data) {
    final session = data.session;
    if (session == null) return AuthState.unauthenticated;
    return AuthState.authenticated;
  });
});
