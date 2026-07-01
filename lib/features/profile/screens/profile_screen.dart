import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error loading profile')),
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));

          final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + Name ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _roleBadgeColor(user.role).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _roleBadgeColor(user.role).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_roleIcon(user.role), size: 14, color: _roleBadgeColor(user.role)),
                            const SizedBox(width: 6),
                            Text(
                              _roleLabel(user.role),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _roleBadgeColor(user.role),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats Grid ─────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _StatsGrid(memberSince: user.createdAt),
                ),

                // ── Invite Code (caregiver only) ───────────────────────────
                if (user.role == 'caregiver' && user.inviteCode != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.caregiverLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.caregiver.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              user.inviteCode!,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.caregiver,
                                letterSpacing: 8,
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
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
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
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
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
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
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
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
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever_outlined, size: 18),
                    label: const Text('Delete Account'),
                    onPressed: () => _deleteAccount(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _roleBadgeColor(String role) {
    switch (role) {
      case 'caregiver': return AppColors.caregiver;
      case 'linked_patient': return AppColors.linked;
      default: return AppColors.primary;
    }
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

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends ConsumerWidget {
  final DateTime? memberSince;
  const _StatsGrid({this.memberSince});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = memberSince != null
        ? '${memberSince!.day}/${memberSince!.month}/${memberSince!.year}'
        : 'N/A';
    final stats = ref.watch(profileStatsProvider);
    final s = stats.value;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _StatCell('Medicines', '${s?['medicines'] ?? 0}', Icons.medication_outlined, AppColors.primary),
        _StatCell('Reminders', '${s?['reminders'] ?? 0}', Icons.alarm_outlined, AppColors.caregiver),
        _StatCell('Taken', '${s?['taken'] ?? 0}', Icons.check_circle_outline, AppColors.success),
        _StatCell('Adherence', s != null ? '${s['adherence']}%' : '—%', Icons.trending_up_outlined, AppColors.primary),
        _StatCell('Streak', '${s?['streak'] ?? 0}d', Icons.local_fire_department_outlined, AppColors.warning),
        _StatCell('Member', joined, Icons.calendar_today_outlined, AppColors.textSecondary),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCell(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
