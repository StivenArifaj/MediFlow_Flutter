import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

final historyProvider = FutureProvider.family<List<HistoryEntry>, int>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.historyDao.getHistoryForUser(userId);
});

final medicineNameProvider = FutureProvider.family<String?, int>((ref, id) async {
  final db = ref.watch(appDatabaseProvider);
  final m = await db.medicinesDao.getMedicineById(id);
  return m?.verifiedName;
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _dateFilter = '30';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);
    final userId = repo.currentUserId;
    final histAsync = userId != null
        ? ref.watch(historyProvider(userId))
        : const AsyncValue<List<HistoryEntry>>.data([]);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    Text('Medication History', style: AppTypography.headlineMedium()),
                  ],
                ),
              ),
            ),

            Expanded(
              child: histAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
                error: (_, __) => const Center(child: Text('Error loading history')),
                data: (history) {
                  final now = DateTime.now();
                  final filtered = history.where((h) {
                    final daysDiff = now.difference(h.scheduledTime).inDays;
                    final dateOk = _dateFilter == 'all'
                        ? true
                        : daysDiff <= int.parse(_dateFilter);
                    final statusOk = _statusFilter == 'all' || h.status == _statusFilter;
                    return dateOk && statusOk;
                  }).toList();

                  final taken = filtered.where((h) => h.status == 'taken').length;
                  final skipped = filtered.where((h) => h.status == 'skipped').length;
                  final missed = filtered.where((h) => h.status == 'missed').length;
                  final total = filtered.length;
                  final pct = total > 0 ? (taken / total * 100).round() : 0;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          child: Column(
                            children: [
                              _AdherenceCard(
                                taken: taken,
                                skipped: skipped,
                                missed: missed,
                                total: total,
                                percent: pct,
                              ).animate().fadeIn(duration: 400.ms),

                              const SizedBox(height: AppDimensions.md),

                              _FilterBar(
                                dateFilter: _dateFilter,
                                statusFilter: _statusFilter,
                                onDateChanged: (v) => setState(() => _dateFilter = v),
                                onStatusChanged: (v) => setState(() => _statusFilter = v),
                              ),

                              const SizedBox(height: AppDimensions.sm),
                            ],
                          ),
                        ),
                      ),

                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Glowing empty state
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.neonCyan.withValues(alpha: 0.06),
                                    boxShadow: const [
                                      BoxShadow(color: AppColors.neonCyanGlow, blurRadius: 40),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('💊', style: TextStyle(fontSize: 48)),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.md),
                                Text('No history yet',
                                    style: AppTypography.titleLarge()),
                                const SizedBox(height: AppDimensions.xs),
                                Text('Your dose history will appear here',
                                    style: AppTypography.bodySmall()),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.md,
                                vertical: AppDimensions.xs,
                              ),
                              child: _HistoryEntryCard(entry: filtered[i])
                                  .animate()
                                  .fadeIn(delay: Duration(milliseconds: i * 30), duration: 250.ms),
                            ),
                            childCount: filtered.length,
                          ),
                        ),
                    ],
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

// ── Adherence Card ────────────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  final int taken, skipped, missed, total, percent;
  const _AdherenceCard({
    required this.taken,
    required this.skipped,
    required this.missed,
    required this.total,
    required this.percent,
  });

  String get _message {
    if (percent >= 90) return '🏆 Outstanding! You\'re a medicine hero!';
    if (percent >= 75) return '💪 Great job! Keep it up!';
    if (percent >= 50) return '👍 Good progress! You can do even better.';
    return '💙 Every dose counts. Let\'s get back on track.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: AppColors.neonCardDecoration,
      child: Column(
        children: [
          Text('Last 30 Days Adherence',
              style: AppTypography.titleMedium()),
          const SizedBox(height: AppDimensions.md),

          // Glowing ring (reused)
          AdherenceRing(
            percent: total > 0 ? taken / total * 100 : 0,
            size: 140,
          ),

          const SizedBox(height: AppDimensions.xs),
          Text('Last 30 Days', style: AppTypography.bodySmall(color: AppColors.textMuted)),

          const SizedBox(height: AppDimensions.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip('Taken', taken, AppColors.success),
              _StatChip('Skipped', skipped, AppColors.info),
              _StatChip('Missed', missed, AppColors.error),
            ],
          ),

          if (total > 0) ...[
            const SizedBox(height: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2535),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(_message,
                  style: AppTypography.bodySmall(), textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text('$count', style: AppTypography.titleLarge(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall()),
        ],
      ),
    );
  }
}

// ── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String dateFilter, statusFilter;
  final ValueChanged<String> onDateChanged, onStatusChanged;

  const _FilterBar({
    required this.dateFilter,
    required this.statusFilter,
    required this.onDateChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip('Today', '1', dateFilter, onDateChanged),
              _FilterChip('7 Days', '7', dateFilter, onDateChanged),
              _FilterChip('30 Days', '30', dateFilter, onDateChanged),
              _FilterChip('All Time', 'all', dateFilter, onDateChanged),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip('All', 'all', statusFilter, onStatusChanged),
              _FilterChip('✅ Taken', 'taken', statusFilter, onStatusChanged),
              _FilterChip('⏭️ Skipped', 'skipped', statusFilter, onStatusChanged),
              _FilterChip('❌ Missed', 'missed', statusFilter, onStatusChanged),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, current;
  final ValueChanged<String> onTap;

  const _FilterChip(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: active ? AppColors.neonCyan : const Color(0x1A00E5FF),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(
              color: active ? AppColors.bgPrimary : AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── History Entry Card ─────────────────────────────────────────────────────────

class _HistoryEntryCard extends ConsumerWidget {
  final HistoryEntry entry;
  const _HistoryEntryCard({required this.entry});

  Color _statusColor(String status) {
    switch (status) {
      case 'taken': return AppColors.statusTaken;
      case 'skipped': return AppColors.statusSkipped;
      case 'missed': return AppColors.statusMissed;
      default: return AppColors.statusPending;
    }
  }

  String _statusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(medicineNameProvider(entry.medicineId));
    final name = nameAsync.value ?? '—';
    final color = _statusColor(entry.status);
    final isTaken = entry.status == 'taken';
    final isMissed = entry.status == 'missed';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: AppColors.neonCardDecoration,
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleMedium()),
                Text(
                  DateFormat('d MMM, HH:mm').format(entry.scheduledTime),
                  style: AppTypography.bodySmall(),
                ),
                if (entry.actualTime != null)
                  Text(
                    'Taken: ${DateFormat('HH:mm').format(entry.actualTime!)}',
                    style: AppTypography.bodySmall(color: AppColors.statusTaken),
                  ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isTaken
                  ? color
                  : isMissed
                      ? color
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              _statusLabel(entry.status),
              style: AppTypography.bodySmall(
                color: isTaken || isMissed
                    ? (isTaken ? AppColors.bgPrimary : AppColors.textPrimary)
                    : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
