import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/locale/locale_provider.dart';
import 'core/services/missed_dose_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'data/database/app_database.dart';

class MediFlowApp extends ConsumerStatefulWidget {
  const MediFlowApp({super.key});

  @override
  ConsumerState<MediFlowApp> createState() => _MediFlowAppState();
}

class _MediFlowAppState extends ConsumerState<MediFlowApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run missed dose check on app launch
    _checkMissedDoses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkMissedDoses();
    }
  }

  Future<void> _checkMissedDoses() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(authRepositoryProvider).currentUserId;
      if (userId != null) {
        await MissedDoseService.checkAndMarkMissed(db, userId);
      }
    } catch (_) {
      // Silently fail — user may not be logged in yet
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MediFlow',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('sq', ''), // Albanian (default)
        Locale('en', ''), // English
        Locale('de', ''), // German
        Locale('fr', ''), // French
      ],
      locale: locale,

      // Router
      routerConfig: appRouter,
    );
  }
}
