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
      backgroundColor: Colors.transparent,
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

              // 30-day trend line chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _TrendCard(history: history),
                ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
              ),

              // Month calendar with tappable days
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _MonthCalendarCard(
                    history: history,
                    onDayTap: (day, entries) =>
                        _showDaySheet(day, entries),
                  ),
                ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
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
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: 20),
                        const Text('No history yet',
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

// ── Day Detail Sheet ──────────────────────────────────────────────────────────

extension _DaySheetX on _HistoryScreenState {
  void _showDaySheet(DateTime day, List<Map<String, dynamic>> entries) {
    final taken = entries.where((h) {
      final s = h['status'] as String;
      return s == 'taken' || s == 'taken_late';
    }).length;
    final missed = entries.where((h) => h['status'] == 'missed').length;
    final skipped = entries.where((h) => h['status'] == 'skipped').length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, d MMMM').format(day),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${entries.length} dose${entries.length == 1 ? '' : 's'} scheduled',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(children: [
              _DayStat(count: taken, label: 'Taken', color: AppColors.success),
              const SizedBox(width: 10),
              _DayStat(
                  count: skipped,
                  label: 'Skipped',
                  color: AppColors.textSecondary),
              const SizedBox(width: 10),
              _DayStat(count: missed, label: 'Missed', color: AppColors.danger),
            ]),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Nothing logged on this day',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textTertiary)),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: entries
                      .map((e) => _HistoryRow(entry: e))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _DayStat({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.8))),
        ]),
      ),
    );
  }
}

// ── 30-Day Trend Card ─────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _TrendCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: 29 - i));
      final entries = history.where((h) {
        final dt = DateTime.parse(h['scheduled_time'] as String);
        return dt.year == day.year &&
            dt.month == day.month &&
            dt.day == day.day;
      }).toList();
      if (entries.isEmpty) continue;
      final taken = entries.where((h) {
        final s = h['status'] as String;
        return s == 'taken' || s == 'taken_late';
      }).length;
      spots.add(FlSpot(i.toDouble(), taken / entries.length * 100));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.show_chart_rounded,
                color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text('30-Day Trend',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: spots.length < 2
                ? const Center(
                    child: Text('Log a few more days to see your trend',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textTertiary)),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 105,
                      minX: 0,
                      maxX: 29,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (_) => const FlLine(
                            color: AppColors.divider, strokeWidth: 1),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.18),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('30 days ago',
                  style:
                      TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              Text('Today',
                  style:
                      TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Month Calendar Card ───────────────────────────────────────────────────────

class _MonthCalendarCard extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final void Function(DateTime day, List<Map<String, dynamic>> entries)
      onDayTap;
  const _MonthCalendarCard({required this.history, required this.onDayTap});

  List<Map<String, dynamic>> _entriesFor(DateTime day) {
    return history.where((h) {
      final dt = DateTime.parse(h['scheduled_time'] as String);
      return dt.year == day.year &&
          dt.month == day.month &&
          dt.day == day.day;
    }).toList();
  }

  Color? _dayColor(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return null;
    if (entries.any((e) => e['status'] == 'missed')) return AppColors.danger;
    if (entries.any((e) => e['status'] == 'skipped')) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final startWeekday = DateTime(now.year, now.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calendar_month_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(DateFormat('MMMM yyyy').format(now),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            const Text('Tap a day',
                style:
                    TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 14),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth + startWeekday - 1,
            itemBuilder: (ctx, idx) {
              if (idx < startWeekday - 1) return const SizedBox.shrink();
              final dayNum = idx - startWeekday + 2;
              if (dayNum > daysInMonth) return const SizedBox.shrink();
              final day = DateTime(now.year, now.month, dayNum);
              final entries = _entriesFor(day);
              final color = _dayColor(entries);
              final isToday = dayNum == now.day;
              final isFuture = day.isAfter(now);

              return GestureDetector(
                onTap: isFuture ? null : () => onDayTap(day, entries),
                child: Container(
                  decoration: BoxDecoration(
                    color: color != null
                        ? color.withValues(alpha: 0.14)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isFuture
                              ? AppColors.textTertiary
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      if (color != null)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.success, 'All taken'),
              const SizedBox(width: 16),
              _legendDot(AppColors.warning, 'Skipped'),
              const SizedBox(width: 16),
              _legendDot(AppColors.danger, 'Missed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
    ]);
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
