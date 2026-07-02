import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../home/today_schedule_provider.dart';

class LinkedPatientHome extends ConsumerWidget {
  const LinkedPatientHome({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(todayScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CaregiverBanner(ref: ref),
                  const SizedBox(height: 12),
                  Text(
                    _greeting(),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Today's Medicines",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _todayDate(),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const Divider(height: 1, color: AppColors.border),

            // BODY
            Expanded(
              child: scheduleAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.linked),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (slots) {
                  if (slots.isEmpty) return const _EmptyState();

                  final pending =
                      slots.where((s) => !s.isDone).toList();
                  final allDone = pending.isEmpty;

                  if (allDone) return const _AllDoneState();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: slots.length,
                    itemBuilder: (_, i) {
                      final slot = slots[i];
                      if (slot.isDone) {
                        return _TakenCard(slot: slot)
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: i * 60),
                                duration: 300.ms);
                      }
                      return _PendingCard(
                        slot: slot,
                        onTake: () => ref
                            .read(doseLoggerProvider.notifier)
                            .logDose(
                              reminderId: slot.reminderId,
                              medicineId: slot.medicineId,
                              scheduledAt: slot.scheduledAt,
                              action: 'taken',
                              existingEntryId: slot.historyEntryId,
                            ),
                        onSkip: () => ref
                            .read(doseLoggerProvider.notifier)
                            .logDose(
                              reminderId: slot.reminderId,
                              medicineId: slot.medicineId,
                              scheduledAt: slot.scheduledAt,
                              action: 'skipped',
                              existingEntryId: slot.historyEntryId,
                            ),
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: i * 60),
                          duration: 300.ms);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverBanner extends ConsumerWidget {
  const _CaregiverBanner({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _resolveName(ref),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.linkedLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded,
                  size: 14, color: AppColors.linked),
              const SizedBox(width: 6),
              Text(
                'Managed by ${snap.data}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.linked,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.linkedLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Text('💊', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
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
                      if (slot.strength != null)
                        Text(
                          slot.strength!,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Skip',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Took It'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.success, width: 4),
        ),
        boxShadow: AppColors.sm,
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('💊', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slot.medicineName,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textSecondary),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                SizedBox(width: 4),
                Text('Taken',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    )),
              ],
            ),
          ],
        ),
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
        children: const [
          Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
          SizedBox(height: 16),
          Text(
            'All done for today!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
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
        children: const [
          Icon(Icons.medication_outlined,
              size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No medicines yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
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
