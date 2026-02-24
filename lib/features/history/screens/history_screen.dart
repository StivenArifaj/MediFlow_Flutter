import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

final historyProvider =
    FutureProvider.family<List<HistoryEntry>, int>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.historyDao.getHistoryForUser(userId);
});

final medicineNameProvider =
    FutureProvider.family<String?, int>((ref, id) async {
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
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: histAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF), strokeWidth: 2)),
          error: (_, __) => const Center(
              child: Text('Error loading history',
                  style: TextStyle(color: Colors.white))),
          data: (history) {
            final now = DateTime.now();
            final filtered = history.where((h) {
              final daysDiff = now.difference(h.scheduledTime).inDays;
              final dateOk = _dateFilter == 'all'
                  ? true
                  : daysDiff <= int.parse(_dateFilter);
              final statusOk =
                  _statusFilter == 'all' || h.status == _statusFilter;
              return dateOk && statusOk;
            }).toList();

            final taken =
                filtered.where((h) => h.status == 'taken').length;
            final skipped =
                filtered.where((h) => h.status == 'skipped').length;
            final missed =
                filtered.where((h) => h.status == 'missed').length;
            final total = filtered.length;
            final pct =
                total > 0 ? (taken / total * 100).round() : 0;

            return CustomScrollView(
              slivers: [
                // ── Safe area top ────────────────────────────────
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(children: [
                        // Section header style
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Medication History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),

                // ── Hero adherence ring ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1826),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF00E5FF)
                                .withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E5FF).withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Ring
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF)
                                      .withOpacity(0.15),
                                  blurRadius: 60,
                                  spreadRadius: 18,
                                ),
                              ],
                            ),
                            child: AdherenceRing(
                              percent: pct.toDouble(),
                              size: 170,
                            ),
                          ).animate().fadeIn(duration: 600.ms).scale(
                              begin: const Offset(0.8, 0.8),
                              curve: Curves.easeOutBack),
                          const SizedBox(height: 6),
                          const Text(
                            'Last 30 Days',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF8A9BB5)),
                          ),
                          const SizedBox(height: 20),

                          // Stat chips row
                          Row(
                            children: [
                              _StatChip(
                                  label: 'Taken',
                                  count: taken,
                                  color: const Color(0xFF00E5FF)),
                              const SizedBox(width: 10),
                              _StatChip(
                                  label: 'Skipped',
                                  count: skipped,
                                  color: const Color(0xFF6B7FCC)),
                              const SizedBox(width: 10),
                              _StatChip(
                                  label: 'Missed',
                                  count: missed,
                                  color: const Color(0xFFFF3B5C)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                ),

                // ── Filter chips ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      children: [
                        // Date filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                  label: 'Today',
                                  value: '1',
                                  current: _dateFilter,
                                  onTap: (v) =>
                                      setState(() => _dateFilter = v)),
                              _FilterChip(
                                  label: '7 Days',
                                  value: '7',
                                  current: _dateFilter,
                                  onTap: (v) =>
                                      setState(() => _dateFilter = v)),
                              _FilterChip(
                                  label: '30 Days',
                                  value: '30',
                                  current: _dateFilter,
                                  onTap: (v) =>
                                      setState(() => _dateFilter = v)),
                              _FilterChip(
                                  label: 'All Time',
                                  value: 'all',
                                  current: _dateFilter,
                                  onTap: (v) =>
                                      setState(() => _dateFilter = v)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                  label: 'All',
                                  value: 'all',
                                  current: _statusFilter,
                                  onTap: (v) =>
                                      setState(() => _statusFilter = v)),
                              _FilterChip(
                                  label: '✅ Taken',
                                  value: 'taken',
                                  current: _statusFilter,
                                  onTap: (v) =>
                                      setState(() => _statusFilter = v)),
                              _FilterChip(
                                  label: '⏭️ Skipped',
                                  value: 'skipped',
                                  current: _statusFilter,
                                  onTap: (v) =>
                                      setState(() => _statusFilter = v)),
                              _FilterChip(
                                  label: '❌ Missed',
                                  value: 'missed',
                                  current: _statusFilter,
                                  onTap: (v) =>
                                      setState(() => _statusFilter = v)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── History list or empty state ───────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing emoji
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF)
                                      .withOpacity(0.2),
                                  blurRadius: 50,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('💊',
                                  style: TextStyle(fontSize: 52)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No history yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your dose history will appear here',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF8A9BB5)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _HistoryEntryCard(
                                entry: filtered[i])
                            .animate()
                            .fadeIn(
                                delay:
                                    Duration(milliseconds: i * 30),
                                duration: 250.ms),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF8A9BB5)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;
  const _FilterChip(
      {required this.label,
      required this.value,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00E5FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active
                ? const Color(0xFF00E5FF)
                : const Color(0xFF2A3A4A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                active ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? const Color(0xFF070B12)
                : const Color(0xFF8A9BB5),
          ),
        ),
      ),
    );
  }
}

// ── History Entry Card ────────────────────────────────────────────────────────
class _HistoryEntryCard extends ConsumerWidget {
  final HistoryEntry entry;
  const _HistoryEntryCard({required this.entry});

  Color _statusColor(String status) {
    switch (status) {
      case 'taken': return const Color(0xFF00E5FF);
      case 'skipped': return const Color(0xFF6B7FCC);
      case 'missed': return const Color(0xFFFF3B5C);
      default: return const Color(0xFFFFB800);
    }
  }

  String _statusEmoji(String status) {
    switch (status) {
      case 'taken': return '✅';
      case 'skipped': return '⏭️';
      case 'missed': return '❌';
      default: return '⏳';
    }
  }

  String _statusLabel(String status) =>
      status[0].toUpperCase() + status.substring(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(medicineNameProvider(entry.medicineId));
    final name = nameAsync.value ?? '—';
    final color = _statusColor(entry.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon square
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _statusEmoji(entry.status),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Scheduled: ${DateFormat('d MMM, HH:mm').format(entry.scheduledTime)}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8A9BB5)),
                ),
                if (entry.actualTime != null)
                  Text(
                    'Taken: ${DateFormat('HH:mm').format(entry.actualTime!)}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF00E5FF)),
                  ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusLabel(entry.status),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ),
        ],
      ),
    );
  }
}