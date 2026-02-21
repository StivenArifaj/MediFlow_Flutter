import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sq.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('sq')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'MediFlow'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Your Smart Medicine Companion'**
  String get appTagline;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_fullName;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get auth_welcomeBack;

  /// No description provided for @auth_createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_createAccount;

  /// No description provided for @auth_alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get auth_alreadyHaveAccount;

  /// No description provided for @auth_dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get auth_dontHaveAccount;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @home_goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get home_goodMorning;

  /// No description provided for @home_goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get home_goodAfternoon;

  /// No description provided for @home_goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get home_goodEvening;

  /// No description provided for @home_goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get home_goodNight;

  /// No description provided for @home_todaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get home_todaysSchedule;

  /// No description provided for @home_myMedicines.
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get home_myMedicines;

  /// No description provided for @home_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get home_seeAll;

  /// No description provided for @home_healthTip.
  ///
  /// In en, this message translates to:
  /// **'Health Tip'**
  String get home_healthTip;

  /// No description provided for @home_medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get home_medicines;

  /// No description provided for @home_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get home_today;

  /// No description provided for @home_reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get home_reminders;

  /// No description provided for @medicines_addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get medicines_addMedicine;

  /// No description provided for @medicines_scanMedicine.
  ///
  /// In en, this message translates to:
  /// **'Scan Medicine Box'**
  String get medicines_scanMedicine;

  /// No description provided for @medicines_addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get medicines_addManually;

  /// No description provided for @medicines_medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicines_medicineName;

  /// No description provided for @medicines_brandName.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get medicines_brandName;

  /// No description provided for @medicines_genericName.
  ///
  /// In en, this message translates to:
  /// **'Generic Name'**
  String get medicines_genericName;

  /// No description provided for @medicines_manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get medicines_manufacturer;

  /// No description provided for @medicines_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get medicines_strength;

  /// No description provided for @medicines_form.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get medicines_form;

  /// No description provided for @medicines_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get medicines_quantity;

  /// No description provided for @medicines_expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get medicines_expiryDate;

  /// No description provided for @medicines_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get medicines_category;

  /// No description provided for @medicines_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get medicines_notes;

  /// No description provided for @medicines_setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get medicines_setReminder;

  /// No description provided for @medicines_editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get medicines_editMedicine;

  /// No description provided for @medicines_deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get medicines_deleteMedicine;

  /// No description provided for @medicines_noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines added yet'**
  String get medicines_noMedicines;

  /// No description provided for @reminders_setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get reminders_setReminder;

  /// No description provided for @reminders_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get reminders_morning;

  /// No description provided for @reminders_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get reminders_afternoon;

  /// No description provided for @reminders_evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get reminders_evening;

  /// No description provided for @reminders_bedtime.
  ///
  /// In en, this message translates to:
  /// **'Before Bed'**
  String get reminders_bedtime;

  /// No description provided for @reminders_customTime.
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get reminders_customTime;

  /// No description provided for @reminders_everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every Day'**
  String get reminders_everyDay;

  /// No description provided for @reminders_specificDays.
  ///
  /// In en, this message translates to:
  /// **'Specific Days'**
  String get reminders_specificDays;

  /// No description provided for @reminders_everyXDays.
  ///
  /// In en, this message translates to:
  /// **'Every X Days'**
  String get reminders_everyXDays;

  /// No description provided for @reminders_asNeeded.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get reminders_asNeeded;

  /// No description provided for @reminders_ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get reminders_ongoing;

  /// No description provided for @reminders_untilDate.
  ///
  /// In en, this message translates to:
  /// **'Until Specific Date'**
  String get reminders_untilDate;

  /// No description provided for @reminders_forXDays.
  ///
  /// In en, this message translates to:
  /// **'For X Days'**
  String get reminders_forXDays;

  /// No description provided for @health_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Health Dashboard'**
  String get health_dashboard;

  /// No description provided for @health_trackVitals.
  ///
  /// In en, this message translates to:
  /// **'Track your vital signs'**
  String get health_trackVitals;

  /// No description provided for @health_addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get health_addMeasurement;

  /// No description provided for @health_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get health_weight;

  /// No description provided for @health_bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get health_bloodPressure;

  /// No description provided for @health_heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get health_heartRate;

  /// No description provided for @health_bloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose'**
  String get health_bloodGlucose;

  /// No description provided for @health_temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get health_temperature;

  /// No description provided for @health_spo2.
  ///
  /// In en, this message translates to:
  /// **'SpO2'**
  String get health_spo2;

  /// No description provided for @health_steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get health_steps;

  /// No description provided for @health_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get health_sleep;

  /// No description provided for @health_waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get health_waterIntake;

  /// No description provided for @health_bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get health_bmi;

  /// No description provided for @health_cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get health_cholesterol;

  /// No description provided for @health_waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get health_waist;

  /// No description provided for @health_respiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate'**
  String get health_respiratoryRate;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'Medication History'**
  String get history_title;

  /// No description provided for @history_adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get history_adherence;

  /// No description provided for @history_last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get history_last30Days;

  /// No description provided for @history_taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get history_taken;

  /// No description provided for @history_skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get history_skipped;

  /// No description provided for @history_missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get history_missed;

  /// No description provided for @history_currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get history_currentStreak;

  /// No description provided for @history_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get history_days;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profile_appearance;

  /// No description provided for @profile_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profile_darkMode;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_notifications;

  /// No description provided for @profile_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get profile_privacy;

  /// No description provided for @profile_dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get profile_dataManagement;

  /// No description provided for @profile_exportData.
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get profile_exportData;

  /// No description provided for @profile_clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get profile_clearData;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_about;

  /// No description provided for @profile_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profile_version;

  /// No description provided for @role_patient.
  ///
  /// In en, this message translates to:
  /// **'I am a Patient'**
  String get role_patient;

  /// No description provided for @role_caregiver.
  ///
  /// In en, this message translates to:
  /// **'I am a Caregiver'**
  String get role_caregiver;

  /// No description provided for @role_patientDesc.
  ///
  /// In en, this message translates to:
  /// **'I manage my own medicines'**
  String get role_patientDesc;

  /// No description provided for @role_caregiverDesc.
  ///
  /// In en, this message translates to:
  /// **'I help someone else with their medicines'**
  String get role_caregiverDesc;

  /// No description provided for @role_whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get role_whoAreYou;

  /// No description provided for @role_helpPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience'**
  String get role_helpPersonalize;

  /// No description provided for @role_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get role_continue;

  /// No description provided for @welcome_featureOcr.
  ///
  /// In en, this message translates to:
  /// **'OCR Scan'**
  String get welcome_featureOcr;

  /// No description provided for @welcome_featureReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get welcome_featureReminders;

  /// No description provided for @welcome_featureMetrics.
  ///
  /// In en, this message translates to:
  /// **'13 Health Metrics'**
  String get welcome_featureMetrics;

  /// No description provided for @welcome_featurePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private & Offline'**
  String get welcome_featurePrivate;

  /// No description provided for @auth_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get auth_nameRequired;

  /// No description provided for @auth_emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get auth_emailRequired;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get auth_passwordRequired;

  /// No description provided for @auth_passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get auth_passwordMinLength;

  /// No description provided for @auth_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_passwordMismatch;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get auth_emailInvalid;

  /// No description provided for @auth_emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get auth_emailAlreadyExists;

  /// No description provided for @auth_invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get auth_invalidCredentials;

  /// No description provided for @onboarding_trackMedicines.
  ///
  /// In en, this message translates to:
  /// **'Track All Your Medicines'**
  String get onboarding_trackMedicines;

  /// No description provided for @onboarding_trackMedicinesDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize every medicine in one place. Never forget a dose again.'**
  String get onboarding_trackMedicinesDesc;

  /// No description provided for @onboarding_smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get onboarding_smartReminders;

  /// No description provided for @onboarding_smartRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get personalized notifications at exactly the right time.'**
  String get onboarding_smartRemindersDesc;

  /// No description provided for @onboarding_monitorHealth.
  ///
  /// In en, this message translates to:
  /// **'Monitor Your Health'**
  String get onboarding_monitorHealth;

  /// No description provided for @onboarding_monitorHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Track 13 vital signs and see your adherence improve over time.'**
  String get onboarding_monitorHealthDesc;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// No description provided for @onboarding_getStartedCta.
  ///
  /// In en, this message translates to:
  /// **'Get Started →'**
  String get onboarding_getStartedCta;

  /// No description provided for @disclaimer_title.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get disclaimer_title;

  /// No description provided for @disclaimer_text.
  ///
  /// In en, this message translates to:
  /// **'MediFlow is a medication organization tool only. It does not provide medical advice, diagnosis, or treatment. Always consult your healthcare provider before making any medical decisions.'**
  String get disclaimer_text;

  /// No description provided for @scan_title.
  ///
  /// In en, this message translates to:
  /// **'Scan Medicine Box'**
  String get scan_title;

  /// No description provided for @scan_alignFrame.
  ///
  /// In en, this message translates to:
  /// **'Align medicine name within the frame'**
  String get scan_alignFrame;

  /// No description provided for @scan_manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get scan_manualEntry;

  /// No description provided for @scan_processing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing medicine...'**
  String get scan_processing;

  /// No description provided for @scan_noTextDetected.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this image — try better lighting or Manual Entry'**
  String get scan_noTextDetected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sq':
      return AppLocalizationsSq();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
