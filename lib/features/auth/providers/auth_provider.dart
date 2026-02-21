import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/auth_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main() before runApp',
  );
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepository(database: db, prefs: prefs);
});

final authStateProvider = FutureProvider<AuthState>((ref) async {
  final repo = ref.watch(authRepositoryProvider);

  if (!repo.hasSeenOnboarding) {
    return AuthState.onboarding;
  }

  final hasSession = await repo.hasValidSession();
  if (hasSession) {
    return AuthState.authenticated;
  }

  return AuthState.unauthenticated;
});

enum AuthState {
  onboarding,
  unauthenticated,
  authenticated,
}
