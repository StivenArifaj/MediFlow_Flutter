import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

const _keyThemeMode = 'mediflow_theme_mode';

/// Theme mode notifier — persists to SharedPreferences
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_keyThemeMode);
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.dark; // default
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _persist(mode);
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _persist(state);
  }

  void _persist(ThemeMode mode) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_keyThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Convenience provider
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeProvider);
});
