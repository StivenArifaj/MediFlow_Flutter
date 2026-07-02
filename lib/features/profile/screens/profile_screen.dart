import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/supabase_data_service.dart';
import '../../../core/hooks/managed_user_id.dart';
import '../profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));

          final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M';

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    decoration: AppColors.gradientCard(
                        const [Color(0xFF1E3A5F), Color(0xFF2D7DD2)],
                        radius: 28),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          const Positioned(
                              top: -60, right: -50,
                              child: DecorCircle(size: 170)),
                          const Positioned(
                              bottom: -80, left: -30,
                              child: DecorCircle(size: 150, opacity: 0.08)),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2),
                          ),
                          child: Center(
                            child: Text(initial,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 3),
                              Text(user.email,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(alpha: 0.75))),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_roleIcon(user.role),
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(_roleLabel(user.role),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 50.ms)
                      .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                // ── Stats Row ─────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.cardRadius),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: _StatsRow(memberSince: user.createdAt),
                ),

                // ── Invite Code (caregiver only) ───────────────────────────
                if (user.role == 'caregiver' && user.inviteCode != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppColors.cardRadius),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 3,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.caregiver,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Patient Invite Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        const Text(
                          'Share this code with your patient. They enter it when registering.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.caregiverLight,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              user.inviteCode!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.caregiver,
                                letterSpacing: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy Code'),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: user.inviteCode!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied!')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.caregiver,
                                side: const BorderSide(color: AppColors.caregiver),
                                shape: const StadiumBorder(),
                                minimumSize: const Size(0, 44),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Rotate'),
                              onPressed: () => _regenerateCode(context, ref),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                shape: const StadiumBorder(),
                                minimumSize: const Size(0, 44),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),

                // ── My Patient (caregiver only) ────────────────────────────
                if (user.role == 'caregiver') ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 16, 6),
                    child: Text(
                      'MY PATIENT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(children: [
                      _SettingsTile(
                        icon: Icons.dashboard_outlined,
                        iconColor: AppColors.caregiver,
                        label: 'Caregiver Dashboard',
                        onTap: () => context.push('/caregiver-dashboard'),
                      ),
                      Divider(height: 1, color: AppColors.divider, indent: 56),
                      _SettingsTile(
                        icon: Icons.person_outlined,
                        iconColor: AppColors.caregiver,
                        label: 'Patient Status',
                        trailing: Builder(builder: (ctx) {
                          final patient = ref.watch(linkedPatientProvider);
                          final name = patient.value?['name'] as String?;
                          return Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(name ?? 'Not linked',
                                style: TextStyle(
                                    color: name != null ? AppColors.textPrimary : AppColors.textTertiary,
                                    fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                          ]);
                        }),
                        onTap: () => context.push('/caregiver-dashboard'),
                      ),
                      if (ref.watch(linkedPatientProvider).value != null) ...[
                        Divider(height: 1, color: AppColors.divider, indent: 56),
                        _SettingsTile(
                          icon: Icons.link_off_rounded,
                          iconColor: AppColors.danger,
                          label: 'Unlink Patient',
                          labelColor: AppColors.danger,
                          onTap: () => _unlinkPatient(context, ref),
                        ),
                      ],
                    ]),
                  ),
                ],

                // ── Preferences ────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 16, 6),
                  child: Text(
                    'PREFERENCES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(children: [
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      iconColor: AppColors.primary,
                      label: 'Language',
                      trailing: Text(
                        _getLanguageName(ref.watch(localeProvider).languageCode),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      onTap: () => _showLanguageSheet(context, ref),
                    ),
                    Divider(height: 1, color: AppColors.divider, indent: 56),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      label: 'Notifications',
                      trailing: Switch.adaptive(
                        value: user.notificationsEnabled,
                        onChanged: (v) => _toggleNotifications(context, ref, user, v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ]),
                ),

                // ── Data ───────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 16, 6),
                  child: Text(
                    'DATA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(children: [
                    _SettingsTile(
                      icon: Icons.file_download_outlined,
                      iconColor: AppColors.success,
                      label: 'Export My Data',
                      onTap: () => _exportAndShareData(context, ref),
                    ),
                    Divider(height: 1, color: AppColors.divider, indent: 56),
                    _SettingsTile(
                      icon: Icons.cloud_outlined,
                      iconColor: AppColors.primary,
                      label: 'Cloud Backup',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Premium',
                          style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider, indent: 56),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textTertiary,
                      label: 'About MediFlow',
                      trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                      onTap: () => context.push('/about'),
                    ),
                  ]),
                ),

                // ── Account ────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 16, 6),
                  child: Text(
                    'ACCOUNT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(children: [
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      iconColor: AppColors.success,
                      label: 'My Role',
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          user.role == 'caregiver' ? 'Caregiver' : 'Patient',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                      ]),
                      onTap: () => _showRoleInfoModal(context, user),
                    ),
                    Divider(height: 1, color: AppColors.divider, indent: 56),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.danger,
                      label: 'Log Out',
                      labelColor: AppColors.danger,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ]),
                ),

                // ── Delete Account ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever_outlined, size: 18),
                    label: const Text('Delete Account'),
                    onPressed: () => _deleteAccount(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                      minimumSize: const Size(double.infinity, 52),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  IconData _roleIcon(String role) {
    switch (role) {
      case 'caregiver': return Icons.people_rounded;
      case 'linked_patient': return Icons.link_rounded;
      default: return Icons.medication_rounded;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'caregiver': return 'Caregiver';
      case 'linked_patient': return 'Linked Patient';
      default: return 'Patient';
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Log out of MediFlow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(ctx);
                await ref.read(authRepositoryProvider).logout();
                if (ctx.mounted) ctx.go('/welcome');
              } catch (e) {
                // ignore
              }
            },
            child: Text('Log Out', style: TextStyle(color: AppColors.danger)),
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
      backgroundColor: AppColors.surface,
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
                    color: currentLocale == lang['code'] ? AppColors.primary : AppColors.border,
                    width: currentLocale == lang['code'] ? 2 : 1,
                  ),
                ),
                tileColor: currentLocale == lang['code'] ? AppColors.primaryLight : AppColors.surfaceVariant,
                title: Text(lang['name']!, style: AppTypography.titleMedium()),
                trailing: currentLocale == lang['code']
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
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

  Future<void> _toggleNotifications(BuildContext context, WidgetRef ref, UserData user, bool enabled) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase.from('profiles').update({'notifications_enabled': enabled}).eq('id', uid);
    ref.invalidate(currentUserProvider);
    if (!enabled) await NotificationService.cancelAll();
  }

  Future<void> _exportAndShareData(BuildContext context, WidgetRef ref) async {
    final userId = await ref.read(managedUserIdProvider.future);
    if (userId == null) return;

    final svc = ref.read(supabaseDataServiceProvider);
    final medicines = await svc.getMedicines(userId);
    final reminders = await svc.getReminders(userId);
    final history = await svc.getHistory(userId);
    final health = await svc.getMeasurements(userId);

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'medicines': medicines.map((m) => {
        'name': m['verified_name'],
        'brand': m['brand_name'],
        'generic': m['generic_name'],
        'strength': m['strength'],
        'form': m['form'],
        'category': m['category'],
        'notes': m['notes'],
      }).toList(),
      'reminders': reminders.map((r) => {
        'medicineId': r['medicine_id'],
        'time': r['time'],
        'frequency': r['frequency'],
      }).toList(),
      'history': history.map((h) => {
        'status': h['status'],
        'scheduledTime': h['scheduled_time'],
        'actualTime': h['actual_time'],
      }).toList(),
      'healthMeasurements': health.map((h) => {
        'type': h['type'],
        'value': h['value'],
        'unit': h['unit'],
        'recordedAt': h['recorded_at'],
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'mediflow_export_$date.json';

    await SharePlus.instance.share(ShareParams(text: jsonString, subject: fileName));
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_rounded, color: AppColors.danger, size: 24),
          const SizedBox(width: 8),
          const Expanded(child: Text('Delete account permanently?')),
        ]),
        content: const Text(
          'This will delete all your medicines, health data, reminders and history. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Continue', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    final deleteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInnerState) {
          final typed = deleteController.text == 'DELETE';
          return AlertDialog(
            title: const Text('Type DELETE to confirm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Type DELETE (all caps) to permanently delete your account.'),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: deleteController,
                  onChanged: (_) => setInnerState(() {}),
                  style: TextStyle(color: AppColors.danger),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.danger, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: typed ? () => Navigator.pop(ctx, true) : null,
                child: Text(
                  'Delete Forever',
                  style: TextStyle(color: typed ? AppColors.danger : AppColors.textTertiary),
                ),
              ),
            ],
          );
        },
      ),
    );
    deleteController.dispose();

    if (confirmed != true || !context.mounted) return;

    await NotificationService.cancelAll();
    await ref.read(authRepositoryProvider).deleteMyAccount();
    if (context.mounted) context.go('/welcome');
  }

  void _regenerateCode(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerate Code?'),
        content: const Text(
          'This will invalidate the old code. Your patient will need the new code to reconnect.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final uid = supabase.auth.currentUser?.id;
              if (uid == null) return;
              final newCode = _generateCode();
              await supabase.from('profiles').update({'invite_code': newCode}).eq('id', uid);
              ref.invalidate(currentUserProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New code: $newCode'), backgroundColor: AppColors.success),
                );
              }
            },
            child: Text('Regenerate', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _unlinkPatient(BuildContext context, WidgetRef ref) {
    final patientName = ref.read(linkedPatientProvider).value?['name'] as String? ?? 'patient';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unlink $patientName?'),
        content: const Text('They will lose access to your managed medicines and reminders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final uid = supabase.auth.currentUser?.id;
              if (uid == null) return;
              await supabase
                  .from('profiles')
                  .update({'caregiver_id': null})
                  .eq('caregiver_id', uid);
              ref.invalidate(linkedPatientProvider);
              ref.invalidate(currentUserProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient unlinked'), backgroundColor: AppColors.warning),
                );
              }
            },
            child: Text('Unlink', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _showRoleInfoModal(BuildContext context, UserData user) {
    final roleName = user.role == 'caregiver' ? 'Caregiver' : 'Patient';
    final roleDesc = user.role == 'caregiver'
        ? "You manage medicines for someone else. Your medicines and reminders sync to your linked patient's device."
        : 'You manage your own medicines. You have full access to all MediFlow features.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Your Role: $roleName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(roleDesc, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your role is set during account creation and cannot be changed.',
                    style: TextStyle(color: AppColors.warning, fontSize: 13),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  final DateTime? memberSince;
  const _StatsRow({this.memberSince});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final s = stats.value;

    return Row(
      children: [
        _ProfileStat('${s?['medicines'] ?? 0}', 'Medicines', Icons.medication_rounded),
        _VerticalDivider(),
        _ProfileStat(s != null ? '${s['adherence']}%' : '—%', 'Adherence', Icons.trending_up_rounded),
        _VerticalDivider(),
        _ProfileStat('${s?['streak'] ?? 0}d', 'Streak', Icons.local_fire_department_rounded),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _ProfileStat(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary,
              fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppColors.border);
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
              : null),
      onTap: onTap,
    );
  }
}
