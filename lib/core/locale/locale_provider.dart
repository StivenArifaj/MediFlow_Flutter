import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shared_preferences_provider.dart';

const _localeKey = 'mediflow_locale';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_localeKey) ?? 'en';
    return Locale(code, '');
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, languageCode);
    state = Locale(languageCode, '');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
