import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/locale/locale_provider.dart';

class MediFlowApp extends ConsumerWidget {
  const MediFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
