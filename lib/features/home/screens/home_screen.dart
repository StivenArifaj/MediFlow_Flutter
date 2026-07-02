import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../features/auth/providers/current_user_provider.dart';
import '../../medicines/providers/medicines_provider.dart';
import '../../../data/services/notification_service.dart';
import '../today_schedule_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _greetingText() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning';
    if (h >= 12 && h < 18) return 'Good Afternoon';
    if (h >= 18 && h < 23) return 'Good Evening';
    return 'Good Night';
  }

  final _tips = const [
    'Take your medicines at the same time each day for better adherence.',
    'Drinking a full glass of water helps medicine absorb better.',
    'Never double up on a missed dose — check with your doctor first.',
    'Store medicines in a cool, dry place away from sunlight.',
    'Set a daily alarm to build a consistent medicine routine.',
    'Keep a list of all your medicines for emergency visits.',
    'Talk to your doctor before stopping any prescribed medicine.',
    'Check expiry dates regularly and dispose of expired medicines safely.',
    'Track your health vitals alongside medicines for best results.',
  ];
  String get _dailyTip => _tips[DateTime.now().day % _tips.length];

  Future<void> _takeDose(TodaySlot slot) async {
    await ref.read(doseLoggerProvider.notifier).logDose(
          reminderId: slot.reminderId,
          medicineId: slot.medicineId,
          scheduledAt: slot.scheduledAt,
          action: 'taken',
          existingEntryId: slot.historyEntryId,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅  ${slot.medicineName} marked as taken'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _skipDose(TodaySlot slot) async {
    await ref.read(doseLoggerProvider.notifier).logDose(
          reminderId: slot.reminderId,
          medicineId: slot.medicineId,
          scheduledAt: slot.scheduledAt,
          action: 'skipped',
          existingEntryId: slot.historyEntryId,
        );
  }

  void _showSnooze(TodaySlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SnoozeSheet(
        medicineName: slot.medicineName,
        notificationId: slot.notificationId,
        snoozeDuration: slot.snoozeDuration,
      ),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
            const Text('Add Medicine',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Choose how to add your medicine',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _AddOptionTile(
              icon: Icons.document_scanner_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primaryLight,
              title: 'Scan Medicine Box',
              subtitle: 'Barcode or OCR text recognition',
              onTap: () {
                Navigator.pop(context);
                context.go('/home/scan');
              },
            ),
            const SizedBox(height: 12),
            _AddOptionTile(
              icon: Icons.edit_note_rounded,
              iconColor: AppColors.success,
              iconBg: AppColors.successLight,
              title: 'Add Manually',
              subtitle: 'Fill in medicine details',
              onTap: () {
                Navigator.pop(context);
                context.go('/home/add-medicine');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.when(
        data: (u) => u, loading: () => null, error: (_, __) => null);
    final isCaregiver = user?.role == 'caregiver';

    final schedule = ref.watch(todayScheduleProvider);
    final medicines = ref.watch(medicinesProvider);

    final slots = schedule.value ?? [];
    final total = slots.length;
    final taken = slots.where((s) => s.isTaken).length;
    final missed = slots.where((s) => s.status == DoseStatus.missed).length;
    final hasMeds = medicines.value?.isNotEmpty == true;

    final name = user?.name.split(' ').first ?? 'there';
    final initials = user?.name.isNotEmpty == true
        ? user!.name
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.darkButton,
          shape: BoxShape.circle,
          boxShadow: AppColors.lg,
        ),
        child: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          onPressed: _showAddSheet,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $name 👋',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _greetingText(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.softShadow,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => context.go('/home/profile'),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  Color(0xFF5B6EF5),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(
                    begin: -0.04,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),

            // Week day strip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: const _WeekStrip(),
              ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
            ),

            // Progress card
            if (total > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _ProgressCard(
                      taken: taken, total: total, missed: missed),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(
                        begin: 0.03,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic),
              ),

            // Schedule header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 20, 14),
                child: Row(
                  children: [
                    const Text('Today',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/home/add-medicine'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: AppColors.pill(AppColors.primary,
                            filled: false),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.primary, size: 15),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
            ),

            // Schedule list
            schedule.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _EmptyState(
                          onAdd: () => context.go('/home/add-medicine')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ScheduleCard(
                        slot: slots[i],
                        onTake: () => _takeDose(slots[i]),
                        onSkip: () => _skipDose(slots[i]),
                        onSnooze: () => _showSnooze(slots[i]),
                      )
                          .animate(
                              delay: Duration(milliseconds: 150 + i * 70))
                          .fadeIn(duration: 300.ms)
                          .slideX(
                              begin: 0.03,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut),
                      childCount: slots.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _EmptyState(
                      onAdd: () => context.go('/home/add-medicine')),
                ),
              ),
            ),

            // Caregiver patient card
            if (isCaregiver)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _MyPatientCard(),
                ),
              ),

            // Health tip
            if (hasMeds)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: _HealthTipCard(tip: _dailyTip),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Week Strip ─────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day.day == now.day && day.month == now.month;
        return Container(
          width: 42,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isToday ? AppColors.darkButton : AppColors.surface,
            borderRadius: BorderRadius.circular(21),
            boxShadow: isToday ? AppColors.md : AppColors.xs,
          ),
          child: Column(
            children: [
              Text(
                letters[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isToday ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Progress Card ──────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int taken, total, missed;
  const _ProgressCard(
      {required this.taken, required this.total, required this.missed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.gradientCard(
          const [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned(
                top: -50, right: -40, child: DecorCircle(size: 160)),
            const Positioned(
                bottom: -70, right: 40,
                child: DecorCircle(size: 140, opacity: 0.05)),
            Padding(
              padding: const EdgeInsets.all(22),
              child: _content(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final progress = total > 0 ? taken / total : 0.0;
    final complete = taken == total && total > 0;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  complete ? 'Complete ✓' : '$taken / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$taken',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 6),
                child: Text(
                  'doses taken',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                missed > 0
                    ? '$missed doses missed'
                    : complete
                        ? 'All done! Great job 🎉'
                        : '${total - taken} remaining',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
              if (missed > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: AppColors.pill(AppColors.warning),
                  child: Text(
                    '$missed missed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
  }
}

// ── Schedule Card ──────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final TodaySlot slot;
  final VoidCallback onTake, onSkip, onSnooze;

  const _ScheduleCard({
    required this.slot,
    required this.onTake,
    required this.onSkip,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay(
      hour: slot.scheduledAt.hour,
      minute: slot.scheduledAt.minute,
    ).format(context);

    if (slot.status == DoseStatus.pending) {
      return _PendingCard(
        slot: slot,
        timeLabel: timeLabel,
        onTake: onTake,
        onSkip: onSkip,
        onSnooze: onSnooze,
      );
    }

    if (slot.status == DoseStatus.taken ||
        slot.status == DoseStatus.takenLate) {
      return _TakenCard(slot: slot, timeLabel: timeLabel);
    }

    // missed / skipped
    final isMissed = slot.status == DoseStatus.missed;
    final statusColor = isMissed ? AppColors.warning : AppColors.textTertiary;
    final statusText = isMissed ? 'Missed' : 'Skipped';
    final statusIcon =
        isMissed ? Icons.warning_amber_rounded : Icons.remove_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              slot.medicineName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final TodaySlot slot;
  final String timeLabel;
  final VoidCallback onTake, onSkip, onSnooze;

  const _PendingCard({
    required this.slot,
    required this.timeLabel,
    required this.onTake,
    required this.onSkip,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [slot.strength, slot.form]
        .where((s) => s?.isNotEmpty == true)
        .join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.medication_rounded,
                      color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.medicineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onSnooze,
                    child: const Icon(Icons.snooze_rounded,
                        color: AppColors.textTertiary, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: const StadiumBorder(),
                      foregroundColor: AppColors.textSecondary,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Skip',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Took It'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkButton,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(44),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TakenCard extends StatelessWidget {
  final TodaySlot slot;
  final String timeLabel;
  const _TakenCard({required this.slot, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
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
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              slot.status == DoseStatus.takenLate ? 'Late' : 'Taken',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Snooze Sheet ───────────────────────────────────────────────────────────────

class _SnoozeSheet extends StatelessWidget {
  final String medicineName;
  final int notificationId;
  final int snoozeDuration;

  const _SnoozeSheet({
    required this.medicineName,
    required this.notificationId,
    required this.snoozeDuration,
  });

  @override
  Widget build(BuildContext context) {
    final options = [5, 10, 15, 30];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Snooze $medicineName', style: AppTypography.h3),
        const SizedBox(height: 20),
        Row(
          children: options
              .map((min) => Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await NotificationService.snoozeReminder(
                          notificationId: notificationId,
                          medicineName: medicineName,
                          snoozeMinutes: min,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text('${min}m',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ── My Patient Card ────────────────────────────────────────────────────────────

class _MyPatientCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _loadPatientData(),
      builder: (context, snap) {
        final patientName = snap.data?['patientName'];
        final inviteCode = snap.data?['inviteCode'];
        final hasPatient = patientName != null && patientName.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.caregiverLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.caregiverLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.caregiver, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Patient', style: AppTypography.label),
                        Text(
                          hasPatient ? patientName : 'No patient linked yet',
                          style: AppTypography.bodySmallStyle,
                        ),
                      ]),
                ),
                TextButton(
                  onPressed: () => context.push('/caregiver-dashboard'),
                  child: Text(
                    hasPatient ? 'View Report →' : 'Dashboard →',
                    style: const TextStyle(color: AppColors.caregiver),
                  ),
                ),
              ]),
              if (inviteCode != null && inviteCode.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.vpn_key_rounded,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Text('Invite Code: ',
                        style: AppTypography.bodySmallStyle),
                    Text(inviteCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        )),
                  ]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String?>> _loadPatientData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final patient = await supabase
        .from('profiles')
        .select('name, email')
        .eq('caregiver_id', userId)
        .maybeSingle();

    final me = await supabase
        .from('profiles')
        .select('invite_code')
        .eq('id', userId)
        .maybeSingle();

    return {
      'patientName': patient?['name'] as String?,
      'inviteCode': me?['invite_code'] as String?,
    };
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 36, color: AppColors.primary),
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
            'Tap the + button to add\nyour first medicine',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Medicine'),
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkButton,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Option Tile ────────────────────────────────────────────────────────────

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.card,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Health Tip Card ────────────────────────────────────────────────────────────

class _HealthTipCard extends StatelessWidget {
  final String tip;
  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE9DC), Color(0xFFEDE4FF), Color(0xFFDDEBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Positioned(
                top: -45, right: -35,
                child: DecorCircle(size: 120, opacity: 0.4)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _row(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row() {
    return Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.xs,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF9333EA), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Tip',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}
