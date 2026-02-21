import 'package:flutter/material.dart';
import 'package:mediflow/l10n/app_localizations.dart';

/// Extension to easily access AppLocalizations
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
