import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _dateFilter = '30';
  String _statusFilter = 'all';

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
        if (i == 0) {
          day = day.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      final hasMissed = dayEntries.any((e) => e['status'] == 'missed');
      if (hasMissed) break;

      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String get _selectedPeriodLabel {
    switch (_dateFilter) {
      case '1': return 'Today';
      case '7': return 'Last 7 days';
      case '30': return 'Last 30 days';
      default: return 'All time';
    }
  }

  Color _adherenceColor(int pct) {
    if (pct >= 80) return AppColors.success;
    if (pct >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final histAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: histAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        error: (_, __) => const Center(
            child: Text('Error loading history')),
        data: (history) {
          final now = DateTime.now();
          final filtered = history.where((h) {
            final dt = DateTime.parse(h['scheduled_time'] as String);
            final daysDiff = now.difference(dt).inDays;
            final dateOk = _dateFilter == 'all'
                ? true
                : daysDiff <= int.parse(_dateFilter);
            final status = h['status'] as String;
            final statusOk = _statusFilter == 'all' || status == _statusFilter;
            return dateOk && statusOk;
          }).toList();

          final taken = filtered.where((h) {
            final s = h['status'] as String;
            return s == 'taken' || s == 'taken_late';
          }).length;
          final skipped =
              filtered.where((h) => h['status'] == 'skipped').length;
          final missed =
              filtered.where((h) => h['status'] == 'missed').length;
          final total = filtered.length;
          final pct = total > 0 ? (taken / total * 100).round() : 0;
          final streak = _calculateStreak(history);

          return CustomScrollView(
            slivers: [
              // ── Adherence summary card ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: _adherenceColor(pct),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('adherence',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary)),
                              Text(_selectedPeriodLabel,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textTertiary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatBox('Taken', taken, AppColors.success),
                          const SizedBox(width: 8),
                          _StatBox('Skipped', skipped, AppColors.textSecondary),
                          const SizedBox(width: 8),
                          _StatBox('Missed', missed, AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔥',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              '$streak day streak',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // ── Filter chips ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Today', '1', _dateFilter,
                                (v) => setState(() => _dateFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('7 Days', '7', _dateFilter,
                                (v) => setState(() => _dateFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('30 Days', '30', _dateFilter,
                                (v) => setState(() => _dateFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('All Time', 'all', _dateFilter,
                                (v) => setState(() => _dateFilter = v)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all', _statusFilter,
                                (v) => setState(() => _statusFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('Taken', 'taken', _statusFilter,
                                (v) => setState(() => _statusFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('Skipped', 'skipped', _statusFilter,
                                (v) => setState(() => _statusFilter = v)),
                            const SizedBox(width: 8),
                            _buildFilterChip('Missed', 'missed', _statusFilter,
                                (v) => setState(() => _statusFilter = v)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── History list ────────────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💊', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 20),
                        const Text('No history yet',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('Your dose history will appear here',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HistoryEntryCard(entry: filtered[i])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: i * 30),
                              duration: 250.ms),
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

  Widget _buildFilterChip(
      String label, String value, String current, ValueChanged<String> onSelect) {
    final selected = current == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelect(value),
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatBox(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History Entry Card ────────────────────────────────────────────────────────
class _HistoryEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryEntryCard({required this.entry});

  Color _statusColor(String status) {
    switch (status) {
      case 'taken':
      case 'taken_late': return AppColors.success;
      case 'skipped': return AppColors.textTertiary;
      case 'missed': return AppColors.warning;
      default: return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    if (status == 'taken_late') return 'Late';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final status = entry['status'] as String;
    final scheduledTime =
        DateTime.parse(entry['scheduled_time'] as String);
    final actualTimeRaw = entry['actual_time'] as String?;
    final actualTime =
        actualTimeRaw != null ? DateTime.parse(actualTimeRaw) : null;
    final medicineName =
        (entry['medicines'] as Map<String, dynamic>?)?['verified_name']
            as String? ??
            '—';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('d MMM, HH:mm').format(scheduledTime),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                if (actualTime != null)
                  Text(
                    'Taken: ${DateFormat('HH:mm').format(actualTime)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          _StatusBadge(status: status, color: color, label: _statusLabel(status)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final String label;
  const _StatusBadge(
      {required this.status, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
