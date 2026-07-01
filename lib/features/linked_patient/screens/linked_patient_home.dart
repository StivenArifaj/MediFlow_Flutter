import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../home/today_schedule_provider.dart';

// ── Linked-patient warm color tokens ─────────────────────────────────────────
class _LP {
  _LP._();
  static const bg         = Color(0xFF0A0E1A);
  static const cardBg     = Color(0xFF111827);
  static const cardBorder = Color(0x1AFFB800);
  static const amber      = Color(0xFFFFB800);
  static const amberGlow  = Color(0x0DFFB800);
  static const textWhite  = Color(0xFFFFFFFF);
  static const textMuted  = Color(0xFF8A8FA8);
}

class LinkedPatientHome extends ConsumerWidget {
  const LinkedPatientHome({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning 🌅';
    if (h >= 12 && h < 18) return 'Good Afternoon 🌤️';
    if (h >= 18 && h < 23) return 'Good Evening 🌙';
    return 'Good Night 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(todayScheduleProvider);

    // Resolve caregiver name from profile data (non-blocking)
    final caregiverName = _CaregiverNameResolver(ref: ref);

    return Scaffold(
      backgroundColor: _LP.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.8,
            colors: [_LP.amberGlow, _LP.bg],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(),
                        style: AppTypography.bodyLarge(color: _LP.textMuted)
                            .copyWith(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text("Today's Medicines",
                        style: AppTypography.headlineLarge(color: _LP.textWhite)
                            .copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Tap each medicine when you take it',
                        style: AppTypography.bodyMedium(color: _LP.textMuted)
                            .copyWith(fontSize: 16)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: AppDimensions.lg),

              // ── Content ─────────────────────────────────────
              Expanded(
                child: scheduleAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _LP.amber, strokeWidth: 2),
                  ),
                  error: (_, __) => const Center(
                    child: Text('Failed to load schedule',
                        style: TextStyle(color: _LP.textMuted)),
                  ),
                  data: (slots) {
                    final pending = slots.where((s) => !s.isDone).toList();
                    final allDone = slots.isNotEmpty && pending.isEmpty;

                    if (slots.isEmpty) return _EmptyState();
                    if (allDone) return _AllDoneState();
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                      itemCount: pending.length,
                      itemBuilder: (ctx, i) {
                        final slot = pending[i];
                        return _MedicineCard(
                          slot: slot,
                          onTakeIt: () => ref
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
                            delay: Duration(milliseconds: i * 60), duration: 300.ms);
                      },
                    );
                  },
                ),
              ),

              // ── Bottom label ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: caregiverName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Resolves caregiver name from Supabase without blocking the screen.
class _CaregiverNameResolver extends ConsumerWidget {
  const _CaregiverNameResolver({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _resolveName(ref),
      builder: (ctx, snap) => Text(
        snap.hasData ? 'Managed by ${snap.data}' : '',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall(color: _LP.textMuted).copyWith(fontSize: 13),
      ),
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

// ── Medicine Card ────────────────────────────────────────────────────────────

class _MedicineCard extends StatelessWidget {
  final TodaySlot slot;
  final VoidCallback onTakeIt;
  final VoidCallback onSkip;

  const _MedicineCard({required this.slot, required this.onTakeIt, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final time = '${slot.scheduledAt.hour.toString().padLeft(2, '0')}:${slot.scheduledAt.minute.toString().padLeft(2, '0')}';
    final subtitle = [slot.form, slot.strength].where((s) => s != null && s.isNotEmpty).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: _LP.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LP.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x0DFFB800), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🕗 $time',
              style: AppTypography.bodyMedium(color: _LP.textMuted).copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(slot.medicineName,
              style: AppTypography.headlineMedium(color: _LP.textWhite)
                  .copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: AppTypography.bodyMedium(color: _LP.textMuted).copyWith(fontSize: 16)),

          const SizedBox(height: AppDimensions.md),

          SizedBox(
            width: double.infinity, height: 68,
            child: _TookItButton(onTap: onTakeIt),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 68,
            child: _SkipButton(onTap: onSkip),
          ),
        ],
      ),
    );
  }
}

class _TookItButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TookItButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00C896), Color(0xFF00A878)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x3300C896), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Center(
            child: Text('✅  TOOK IT',
                style: AppTypography.titleMedium(color: _LP.textWhite)
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _LP.amber, width: 1.5),
          ),
          child: Center(
            child: Text('⏭️  SKIP',
                style: AppTypography.titleMedium(color: _LP.amber)
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppDimensions.md),
          Text('Nothing scheduled today',
              style: AppTypography.headlineMedium(color: _LP.textWhite).copyWith(fontSize: 22)),
          const SizedBox(height: AppDimensions.sm),
          Text('Your caregiver will set up your medicines',
              style: AppTypography.bodyMedium(color: _LP.textMuted).copyWith(fontSize: 16)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── All Done State ───────────────────────────────────────────────────────────

class _AllDoneState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.lg),
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2820),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x3300C896)),
          boxShadow: const [BoxShadow(color: Color(0x2200C896), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppDimensions.md),
            Text('All done for today!',
                style: AppTypography.headlineLarge(color: _LP.textWhite)
                    .copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.sm),
            Text('Great job keeping up with your health 🎉',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge(color: _LP.textMuted).copyWith(fontSize: 18)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
