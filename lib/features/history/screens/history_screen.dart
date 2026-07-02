import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _period = '7d';

  int _calculateStreak(List<Map<String, dynamic>> allEntries) {
    if (allEntries.isEmpty) return 0;
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final e in allEntries) {
      final dt = DateTime.parse(e['scheduled_time'] as String);
      final dayKey = '${dt.year}-${dt.month}-${dt.day}';
      byDay.putIfAbsent(dayKey, () => []).add(e);
    }
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final key = '${day.year}-${day.month}-${day.day}';
      final dayEntries = byDay[key];
      if (dayEntries == null) {
        if (i == 0) { day = day.subtract(const Duration(days: 1)); continue; }
        break;
      }
      if (dayEntries.any((e) => e['status'] == 'missed')) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<Map<String, dynamic>> _filterByPeriod(List<Map<String, dynamic>> all) {
    final now = DateTime.now();
    return all.where((h) {
      final dt = DateTime.parse(h['scheduled_time'] as String);
      final days = now.difference(dt).inDays;
      if (_period == '7d') return days < 7;
      if (_period == '30d') return days < 30;
      return true;
    }).toList();
  }

  List<double> _last7DayRates(List<Map<String, dynamic>> all) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayKey = '${day.year}-${day.month}-${day.day}';
      final entries = all.where((h) {
        final dt = DateTime.parse(h['scheduled_time'] as String);
        return '${dt.year}-${dt.month}-${dt.day}' == dayKey;
      }).toList();
      if (entries.isEmpty) return 0.0;
      final taken = entries.where((h) {
        final s = h['status'] as String;
        return s == 'taken' || s == 'taken_late';
      }).length;
      return taken / entries.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final histAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: histAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        error: (_, __) => const Center(child: Text('Error loading history')),
        data: (history) {
          final filtered = _filterByPeriod(history);
          final taken = filtered.where((h) {
            final s = h['status'] as String;
            return s == 'taken' || s == 'taken_late';
          }).length;
          final missed = filtered.where((h) => h['status'] == 'missed').length;
          final total = filtered.length;
          final pct = total > 0 ? (taken / total * 100).round() : 0;
          final streak = _calculateStreak(history);
          final last7 = _last7DayRates(history);
          final now = DateTime.now();
          final weekLabels = List.generate(7, (i) =>
            DateFormat('E').format(now.subtract(Duration(days: 6 - i))));

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('History',
                          style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        const Text('Your medication journey',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),

              // Period pill tabs
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.chipRadius),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      _PeriodTab('7 Days', _period == '7d', () => setState(() => _period = '7d')),
                      _PeriodTab('30 Days', _period == '30d', () => setState(() => _period = '30d')),
                      _PeriodTab('All Time', _period == 'all', () => setState(() => _period = 'all')),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Adherence card with bar chart
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.cardRadius),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Adherence Rate',
                            style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                          if (pct >= 70)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text('$pct%',
                                    style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: AppColors.success)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('$pct%',
                        style: const TextStyle(
                          fontSize: 56, fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary, letterSpacing: -2, height: 1.0)),
                      const SizedBox(height: 4),
                      const Text('of doses taken on time',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: last7.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value * 100,
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryDark],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: e.key == 6 ? 24 : 20,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: AppColors.surfaceVariant,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weekLabels.map((d) => Text(d,
                          style: const TextStyle(
                            fontSize: 10, color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500))).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ),

              // 3 stat boxes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      _StatBox(
                        value: '$taken', label: 'Doses Taken',
                        color: AppColors.success,
                        icon: Icons.check_circle_outline_rounded),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: '$streak', label: 'Day Streak',
                        color: AppColors.primary,
                        icon: Icons.local_fire_department_outlined),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: '$missed', label: 'Missed',
                        color: missed > 0 ? AppColors.warning : AppColors.textTertiary,
                        icon: Icons.warning_amber_rounded),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
              ),

              // Recent header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Text('Recent Activity',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
                ),
              ),

              // History list
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('💊', style: TextStyle(fontSize: 52)),
                        SizedBox(height: 20),
                        Text('No history yet',
                          style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                        SizedBox(height: 8),
                        Text('Your dose history will appear here',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HistoryRow(entry: filtered[i])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: i * 30), duration: 250.ms),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Period Tab ────────────────────────────────────────────────────────────────
class _PeriodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodTab(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.darkButton : Colors.transparent,
            borderRadius: BorderRadius.circular(AppColors.chipRadius)),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatBox({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(value,
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── History Row ───────────────────────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryRow({required this.entry});

  Color _statusColor(String s) {
    switch (s) {
      case 'taken':
      case 'taken_late': return AppColors.success;
      case 'skipped': return AppColors.textTertiary;
      case 'missed': return AppColors.danger;
      default: return AppColors.warning;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'taken': return Icons.check_circle_rounded;
      case 'taken_late': return Icons.schedule_rounded;
      case 'skipped': return Icons.skip_next_rounded;
      default: return Icons.cancel_rounded;
    }
  }

  String _statusLabel(String s) {
    if (s == 'taken_late') return 'Late';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final status = entry['status'] as String;
    final scheduledTime = DateTime.parse(entry['scheduled_time'] as String);
    final medicineName =
        (entry['medicines'] as Map<String, dynamic>?)?['verified_name'] as String? ?? '—';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(_statusIcon(status), color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicineName,
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(DateFormat('d MMM, HH:mm').format(scheduledTime),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50)),
            child: Text(_statusLabel(status),
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}
