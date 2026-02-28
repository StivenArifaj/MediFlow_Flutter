import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/glass_card.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../medicines/providers/medicines_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/notification_service.dart';
import 'package:drift/drift.dart' show Value;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final medicinesAsync = ref.watch(medicinesProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
          error: (_, __) => const Center(child: Text('Error loading profile')),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Not logged in'));
            }
            final medicineCount = medicinesAsync.value?.length ?? 0;

            return Column(
              children: [
                // ── Header/Profile ──────────────────────────────
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [AppColors.cyanGlowStrong],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
                              style: AppTypography.displayMedium(color: AppColors.bgPrimary),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

                        const SizedBox(height: AppDimensions.sm),

                        Text(user.name,
                            style: AppTypography.headlineMedium().copyWith(fontSize: 22)),
                        Text(user.email,
                            style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(fontSize: 14)),

                        const SizedBox(height: AppDimensions.sm),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: user.role == 'caregiver'
                                  ? AppColors.caregiverAccent
                                  : AppColors.neonCyan,
                            ),
                          ),
                          child: Text(
                            user.role == 'caregiver' ? '🤝 Caregiver' : '💊 Patient',
                            style: AppTypography.labelLarge(
                              color: user.role == 'caregiver'
                                  ? AppColors.caregiverAccent
                                  : AppColors.neonCyan,
                            ),
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                      ],
                    ),
                  ),
                ),

                // ── Scrollable body ──────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats grid
                        _StatsGrid(
                          medicineCount: medicineCount,
                          memberSince: user.createdAt,
                        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                        const SizedBox(height: AppDimensions.md),

                        // Premium Card
                        if (!user.isPremium)
                          _PremiumCard()
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 300.ms)
                              .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: AppDimensions.md),

                        // ── Preferences ────────────────────────────
                        _SettingsSection(
                          title: 'Preferences',
                          children: [
                            _SettingsTile(
                              icon: Icons.language_rounded,
                              iconColor: AppColors.info,
                              label: 'Language',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getLanguageName(ref.watch(localeProvider).languageCode),
                                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: AppDimensions.xs),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                ],
                              ),
                              onTap: () => _showLanguageSheet(context, ref),
                            ),
                          ],
                        ).animate().fadeIn(delay: 350.ms, duration: 300.ms),

                        const SizedBox(height: AppDimensions.sm),

                        // ── Appearance ────────────────────────────
                        _SettingsSection(
                          title: 'Appearance',
                          children: [
                            _SettingsTile(
                              icon: Icons.dark_mode_rounded,
                              iconColor: AppColors.premiumFrom,
                              label: 'Dark Mode',
                              trailing: Switch(
                                value: isDark,
                                onChanged: (v) => ref.read(themeModeProvider.notifier).toggle(),
                                activeThumbColor: AppColors.neonCyan,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

                        const SizedBox(height: AppDimensions.sm),

                        // ── Data ────────────────────────────────
                        _SettingsSection(
                          title: 'Data',
                          children: [
                            if (user.role == 'caregiver') ...[
                              _SettingsTile(
                                icon: Icons.people_rounded,
                                iconColor: AppColors.caregiverAccent,
                                label: 'Caregiver Dashboard',
                                onTap: () => context.push('/caregiver-dashboard'),
                              ),
                              _SettingsTile(
                                icon: Icons.link_rounded,
                                iconColor: AppColors.neonCyan,
                                label: 'My Patient',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ref.watch(sharedPreferencesProvider).getString('caregiver_invite_code') ?? 'Not set',
                                      style: AppTypography.bodySmall(color: AppColors.neonCyan),
                                    ),
                                    const SizedBox(width: AppDimensions.xs),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                  ],
                                ),
                                onTap: () {
                                  final code = ref.read(sharedPreferencesProvider).getString('caregiver_invite_code') ?? '';
                                  context.push('/invite-patient', extra: {'inviteCode': code});
                                },
                              ),
                            ],
                            _SettingsTile(
                              icon: Icons.upload_rounded,
                              iconColor: AppColors.info,
                              label: 'Export & Share Data',
                              onTap: () => _exportAndShareData(context, ref),
                            ),
                            _SettingsTile(
                              icon: Icons.backup_rounded,
                              iconColor: AppColors.success,
                              label: 'Cloud Backup',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: AppColors.premiumGradient,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                ),
                                child: Text('Premium',
                                    style: AppTypography.bodySmall(color: Colors.white)),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 450.ms, duration: 300.ms),

                        const SizedBox(height: AppDimensions.sm),

                        // ── MY PATIENT (Caregiver only) ─────────────
                        if (user.role == 'caregiver') ...[
                          _SettingsSection(
                            title: 'My Patient',
                            children: [
                              _SettingsTile(
                                icon: Icons.link_rounded,
                                iconColor: const Color(0xFF8B5CF6),
                                label: 'Invite Code',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ref.watch(sharedPreferencesProvider).getString('caregiver_invite_code') ?? 'Not set',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.neonCyan,
                                        fontFamily: 'monospace',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.xs),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                  ],
                                ),
                                onTap: () => _showInviteCodeSheet(context, ref),
                              ),
                              _SettingsTile(
                                icon: Icons.person_rounded,
                                iconColor: const Color(0xFF8B5CF6),
                                label: 'Patient Status',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ref.watch(sharedPreferencesProvider).getString('linked_patient_name') ?? 'Not linked',
                                      style: AppTypography.bodySmall(
                                        color: ref.watch(sharedPreferencesProvider).getString('linked_patient_name') != null
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.xs),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                  ],
                                ),
                                onTap: () => context.push('/caregiver-dashboard'),
                              ),
                              _SettingsTile(
                                icon: Icons.refresh_rounded,
                                iconColor: AppColors.warning,
                                label: 'Regenerate Invite Code',
                                onTap: () => _regenerateCode(context, ref),
                              ),
                              if (ref.watch(sharedPreferencesProvider).getString('linked_patient_name') != null)
                                _SettingsTile(
                                  icon: Icons.link_off_rounded,
                                  iconColor: AppColors.error,
                                  label: 'Unlink Patient',
                                  labelColor: AppColors.error,
                                  onTap: () => _unlinkPatient(context, ref),
                                ),
                            ],
                          ).animate().fadeIn(delay: 460.ms, duration: 300.ms),

                          const SizedBox(height: AppDimensions.sm),
                        ],

                        // ── Account ────────────────────────────────
                        _SettingsSection(
                          title: 'Account',
                          children: [
                            _SettingsTile(
                              icon: Icons.person_rounded,
                              iconColor: AppColors.success,
                              label: 'My Role',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.role == 'caregiver' ? 'Caregiver' : 'Patient',
                                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: AppDimensions.xs),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                ],
                              ),
                              onTap: () => _showRoleInfoModal(context, user),
                            ),
                            _SettingsTile(
                              icon: Icons.notifications_rounded,
                              iconColor: AppColors.warning,
                              label: 'Notifications',
                              trailing: Switch(
                                value: user.notificationsEnabled,
                                onChanged: (v) => _toggleNotifications(context, ref, user, v),
                                activeThumbColor: AppColors.neonCyan,
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.info_outline_rounded,
                              iconColor: AppColors.textMuted,
                              label: 'About MediFlow',
                              trailing: Text('v1.0.0', style: AppTypography.bodySmall()),
                              onTap: () => context.push('/about'),
                            ),
                            _SettingsTile(
                              icon: Icons.delete_forever_rounded,
                              iconColor: AppColors.error,
                              label: 'Clear All Data',
                              labelColor: AppColors.error,
                              onTap: () => _clearAllData(context, ref),
                            ),
                            _SettingsTile(
                              icon: Icons.logout_rounded,
                              iconColor: AppColors.error,
                              label: 'Log Out',
                              labelColor: AppColors.error,
                              onTap: () => _confirmLogout(context, ref),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

                        const SizedBox(height: AppDimensions.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Log Out', style: AppTypography.titleLarge()),
        content: Text('Are you sure you want to log out?', style: AppTypography.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/welcome');
            },
            child: Text('Log Out', style: AppTypography.labelLarge(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'sq': return '🇦🇱 Shqip';
      case 'en': return '🇬🇧 English';
      case 'de': return '🇩🇪 Deutsch';
      case 'fr': return '🇫🇷 Français';
      default: return '🇬🇧 English';
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider).languageCode;
    final languages = [
      {'code': 'sq', 'name': '🇦🇱 Shqip'},
      {'code': 'en', 'name': '🇬🇧 English'},
      {'code': 'de', 'name': '🇩🇪 Deutsch'},
      {'code': 'fr', 'name': '🇫🇷 Français'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Language', style: AppTypography.headlineMedium()),
            const SizedBox(height: AppDimensions.lg),
            for (final lang in languages) ...[
              ListTile(
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(lang['code']!);
                  Navigator.pop(ctx);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  side: BorderSide(
                    color: currentLocale == lang['code'] ? AppColors.neonCyan : const Color(0x1A00E5FF),
                    width: currentLocale == lang['code'] ? 2 : 1,
                  ),
                ),
                tileColor: AppColors.bgInput,
                title: Text(lang['name']!, style: AppTypography.titleMedium()),
                trailing: currentLocale == lang['code']
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan)
                    : null,
              ),
              const SizedBox(height: AppDimensions.sm),
            ],
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }

  // ── 2. Notifications toggle ─────────────────────────────────────────
  Future<void> _toggleNotifications(BuildContext context, WidgetRef ref, User user, bool enabled) async {
    final db = ref.read(appDatabaseProvider);
    await db.usersDao.updateUser(
      user.copyWithCompanion(UsersCompanion(notificationsEnabled: Value(enabled))),
    );
    ref.invalidate(currentUserProvider);

    if (!enabled) {
      await NotificationService.cancelAll();
    }
  }

  // ── 3. Export & Share Data ──────────────────────────────────────────
  Future<void> _exportAndShareData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    if (userId == null) return;

    final medicines = await db.medicinesDao.getAllMedicines(userId);
    final reminders = await db.remindersDao.getRemindersForUser(userId);
    final history = await db.historyDao.getHistoryForUser(userId);
    final health = await db.healthDao.getMeasurementsForUser(userId);

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'medicines': medicines.map((m) => {
        'name': m.verifiedName,
        'brand': m.brandName,
        'generic': m.genericName,
        'strength': m.strength,
        'form': m.form,
        'category': m.category,
        'notes': m.notes,
      }).toList(),
      'reminders': reminders.map((r) => {
        'medicineId': r.medicineId,
        'time': r.time,
        'frequency': r.frequency,
      }).toList(),
      'history': history.map((h) => {
        'status': h.status,
        'scheduledTime': h.scheduledTime.toIso8601String(),
        'actualTime': h.actualTime?.toIso8601String(),
      }).toList(),
      'healthMeasurements': health.map((h) => {
        'type': h.type,
        'value': h.value,
        'unit': h.unit,
        'recordedAt': h.recordedAt.toIso8601String(),
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'mediflow_export_$date.json';

    await SharePlus.instance.share(
      ShareParams(text: jsonString, subject: fileName),
    );
  }

  // ── 4. Clear All Data ──────────────────────────────────────────────
  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    // Step 1 confirmation
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text('Clear All Data?', style: AppTypography.titleLarge()),
          ],
        ),
        content: Text(
          'This will permanently delete all your medicines, reminders, health measurements, and history. This action cannot be undone.',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Continue', style: AppTypography.labelLarge(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    // Step 2 — type DELETE
    final deleteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInnerState) {
          final typed = deleteController.text.toUpperCase() == 'DELETE';
          return AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              side: const BorderSide(color: Color(0x1A00E5FF)),
            ),
            title: Text('Type DELETE to confirm', style: AppTypography.titleLarge()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter DELETE below to permanently erase all data.',
                  style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: deleteController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setInnerState(() {}),
                  style: AppTypography.titleMedium(color: AppColors.error),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.bgInput,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0x1A00E5FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: typed ? () => Navigator.pop(ctx, true) : null,
                child: Text(
                  'Erase Everything',
                  style: AppTypography.labelLarge(
                    color: typed ? AppColors.error : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    deleteController.dispose();

    if (confirmed != true || !context.mounted) return;

    // Perform deletion
    final db = ref.read(appDatabaseProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    await NotificationService.cancelAll();
    // Delete all table data
    await db.customStatement('DELETE FROM health_measurements');
    await db.customStatement('DELETE FROM history_entries');
    await db.customStatement('DELETE FROM reminders');
    await db.customStatement('DELETE FROM medicines');
    await db.customStatement('DELETE FROM users');
    await prefs.clear();

    if (context.mounted) context.go('/welcome');
  }

  // ── 5. Invite Code Sheet ──────────────────────────────────────────
  void _showInviteCodeSheet(BuildContext context, WidgetRef ref) {
    final code = ref.read(sharedPreferencesProvider).getString('caregiver_invite_code') ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Invite Code', style: AppTypography.headlineMedium()),
            const SizedBox(height: AppDimensions.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neonCyan,
                    fontFamily: 'monospace',
                    letterSpacing: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      SharePlus.instance.share(ShareParams(
                        text: "Hi! I've set up MediFlow to manage your medicines. Download MediFlow and enter this code: $code to get started.",
                      ));
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Share Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied to clipboard!')),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy_rounded, color: AppColors.neonCyan, size: 18),
                          SizedBox(width: 8),
                          Text('Copy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neonCyan)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 6. Regenerate Code ──────────────────────────────────────────────
  void _regenerateCode(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Regenerate Code?', style: AppTypography.titleLarge()),
        content: Text(
          'This will invalidate the old code. Your patient will need the new code to reconnect.',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final newCode = _generateCode();
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setString('caregiver_invite_code', newCode);

              // Update Firestore if possible
              final uid = prefs.getString('firebase_uid');
              if (uid != null) {
                try {
                  await FirebaseFirestore.instance
                      .collection('caregivers')
                      .doc(uid)
                      .set({'inviteCode': newCode}, SetOptions(merge: true));
                } catch (_) {}
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New code generated: $newCode'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Regenerate', style: AppTypography.labelLarge(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  // ── 7. Unlink Patient ───────────────────────────────────────────────
  void _unlinkPatient(BuildContext context, WidgetRef ref) {
    final patientName = ref.read(sharedPreferencesProvider).getString('linked_patient_name') ?? 'patient';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Unlink $patientName?', style: AppTypography.titleLarge()),
        content: Text(
          'They will lose access to your managed medicines and reminders.',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelLarge(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.remove('linked_patient_name');
              await prefs.remove('linked_patient_uid');

              // Update Firestore
              final uid = prefs.getString('firebase_uid');
              if (uid != null) {
                try {
                  await FirebaseFirestore.instance
                      .collection('caregivers')
                      .doc(uid)
                      .update({'patientName': FieldValue.delete(), 'patientUid': FieldValue.delete()});
                } catch (_) {}
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Patient unlinked'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: Text('Unlink', style: AppTypography.labelLarge(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── Code Generator ──────────────────────────────────────────────────
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous chars
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // ── 8. My Role (read-only modal) ───────────────────────────────────
  void _showRoleInfoModal(BuildContext context, User user) {
    final roleName = user.role == 'caregiver' ? 'Caregiver' : 'Patient';
    final roleDesc = user.role == 'caregiver'
        ? 'You manage medicines for someone else. Your medicines and reminders sync to your linked patient\'s device.'
        : 'You manage your own medicines. You have full access to all MediFlow features.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: Color(0x1A00E5FF)),
        ),
        title: Text('Your Role: $roleName', style: AppTypography.titleLarge()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(roleDesc, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your role is set during account creation and cannot be changed.',
                      style: AppTypography.bodySmall(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it', style: AppTypography.labelLarge(color: AppColors.neonCyan)),
          ),
        ],
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int medicineCount;
  final DateTime memberSince;

  const _StatsGrid({required this.medicineCount, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    final joined = '${memberSince.day}/${memberSince.month}/${memberSince.year}';
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: AppDimensions.sm,
      mainAxisSpacing: AppDimensions.sm,
      childAspectRatio: 1.0,
      children: [
        _StatBox('Medicines', '$medicineCount', Icons.medication_rounded, AppColors.neonCyan),
        _StatBox('Reminders', '0', Icons.alarm_rounded, AppColors.info),
        _StatBox('Doses Taken', '0', Icons.check_circle_rounded, AppColors.success),
        _StatBox('Adherence', '—%', Icons.trending_up_rounded, AppColors.warning),
        _StatBox('Day Streak', '0 🔥', Icons.local_fire_department_rounded, AppColors.error),
        _StatBox('Member Since', joined, Icons.calendar_month_rounded, AppColors.textSecondary),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: AppTypography.titleMedium(color: AppColors.neonCyan),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.bodySmall(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Premium Card ──────────────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumFrom.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppDimensions.sm),
              Text('Upgrade to Premium', style: AppTypography.titleLarge(color: Colors.white)),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...const [
            '• Unlimited medicines',
            '• Cloud backup & sync',
            '• Advanced analytics',
            '• Priority support',
            '• Ad-free experience',
          ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(f,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              )),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.premiumFrom,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              child: const Text('Upgrade Now — \$4.99/year'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Section ──────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimensions.xs),
          child: Text(title.toUpperCase(),
              style: AppTypography.bodySmall(color: AppColors.textMuted)),
        ),
        Container(
          decoration: AppColors.neonCardDecoration,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(label,
                    style: AppTypography.bodyLarge(color: labelColor ?? AppColors.textPrimary)),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
