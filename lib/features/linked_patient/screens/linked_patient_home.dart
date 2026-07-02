import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/circle_button.dart';
import '../../../data/services/alert_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../home/today_schedule_provider.dart';

class LinkedPatientHome extends ConsumerStatefulWidget {
  const LinkedPatientHome({super.key});

  @override
  ConsumerState<LinkedPatientHome> createState() => _LinkedPatientHomeState();
}

class _LinkedPatientHomeState extends ConsumerState<LinkedPatientHome> {
  bool _sendingAlert = false;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning';
    if (h >= 12 && h < 18) return 'Good Afternoon';
    if (h >= 18 && h < 23) return 'Good Evening';
    return 'Good Night';
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: const Text('Log out of MediFlow?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(authRepositoryProvider).logout();
              } catch (_) {}
              if (mounted) context.go('/welcome');
            },
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAlertSheet() {
    if (_sendingAlert) return;
    final messageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
          bool sending = false;
          return StatefulBuilder(builder: (ctx, setInner) {
            Future<void> send() async {
              if (sending) return;
              setInner(() => sending = true);
              final result =
                  await AlertService.sendAlert(message: messageCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              if (result.sent) {
                _snack('Alert sent — your caregiver was notified',
                    AppColors.success);
              } else {
                _snack(result.errorMessage ?? 'Could not send alert',
                    AppColors.danger);
                // brief debounce after a failed attempt
                setState(() => _sendingAlert = true);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) setState(() => _sendingAlert = false);
                });
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.dangerLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos_rounded,
                        color: AppColors.danger, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('Alert Your Caregiver',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text('Your caregiver will be notified immediately',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: messageCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'I feel dizzy / I need help / ...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: sending ? null : send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                    ),
                    child: sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Send Alert'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          });
      },
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(todayScheduleProvider);
    final userAsync = ref.watch(currentUserProvider);
    final firstName =
        userAsync.value?.name.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: GestureDetector(
            onTap: _sendingAlert ? null : _showAlertSheet,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                        color: AppColors.danger, shape: BoxShape.circle),
                    child: const Icon(Icons.sos_rounded,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  const Text('Alert My Caregiver',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _todayDate(),
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    CircleButton(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.danger,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: -0.04,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic),

              // ── Managed-by pill ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _CaregiverBanner(),
                ),
              ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              // ── Body ────────────────────────────────────────
              Expanded(
                child: scheduleAsync.when(
                  loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.linked),
                  ),
                  error: (e, _) => const _EmptyState(),
                  data: (slots) {
                    if (slots.isEmpty) return const _EmptyState();

                    final allDone = slots.every((s) => s.isDone);
                    if (allDone) return const _AllDoneState();

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: slots.length,
                      itemBuilder: (_, i) {
                        final slot = slots[i];
                        if (slot.isDone) {
                          return _TakenCard(slot: slot)
                              .animate(
                                  delay: Duration(milliseconds: 100 + i * 60))
                              .fadeIn(duration: 280.ms)
                              .slideX(begin: 0.03, end: 0, duration: 280.ms);
                        }
                        return _PendingCard(
                          slot: slot,
                          onTake: () =>
                              ref.read(doseLoggerProvider.notifier).logDose(
                                    reminderId: slot.reminderId,
                                    medicineId: slot.medicineId,
                                    scheduledAt: slot.scheduledAt,
                                    action: 'taken',
                                    existingEntryId: slot.historyEntryId,
                                  ),
                          onSkip: () =>
                              ref.read(doseLoggerProvider.notifier).logDose(
                                    reminderId: slot.reminderId,
                                    medicineId: slot.medicineId,
                                    scheduledAt: slot.scheduledAt,
                                    action: 'skipped',
                                    existingEntryId: slot.historyEntryId,
                                  ),
                        )
                            .animate(
                                delay: Duration(milliseconds: 100 + i * 60))
                            .fadeIn(duration: 280.ms)
                            .slideX(begin: 0.03, end: 0, duration: 280.ms);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaregiverBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _resolveName(ref),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(50),
            boxShadow: AppColors.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.linkedLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    size: 13, color: AppColors.linked),
              ),
              const SizedBox(width: 8),
              Text(
                'Cared for by ${snap.data}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _resolveName(WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    if (user?.caregiverId == null) return '';
    final row = await supabase
        .from('profiles')
        .select('name')
        .eq('id', user!.caregiverId!)
        .maybeSingle();
    return row?['name'] as String? ?? '';
  }
}

class _PendingCard extends StatelessWidget {
  final TodaySlot slot;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  const _PendingCard(
      {required this.slot, required this.onTake, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
      hour: slot.scheduledAt.hour,
      minute: slot.scheduledAt.minute,
    ).format(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.linkedLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppColors.linked, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.medicineName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (slot.strength != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          slot.strength!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Skip',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: onTake,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('Took It'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TakenCard extends StatelessWidget {
  final TodaySlot slot;
  const _TakenCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.success, width: 4),
        ),
        boxShadow: AppColors.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              slot.medicineName,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'Taken',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneState extends StatelessWidget {
  const _AllDoneState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 44, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          const Text(
            'All done for today!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Great job keeping up with\nyour medicines',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.linkedLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 40, color: AppColors.linked),
          ),
          const SizedBox(height: 20),
          const Text(
            'No medicines yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your caregiver will add your\nmedicines and reminders.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
