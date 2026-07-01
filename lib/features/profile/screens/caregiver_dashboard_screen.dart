import 'package:flutter/material.dart';
import '../../../../core/widgets/app_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../auth/providers/current_user_provider.dart';
import '../profile_providers.dart';
import '../../home/today_schedule_provider.dart';

const _indigo = Color(0xFF8B5CF6);

class CaregiverDashboardScreen extends ConsumerWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final patientAsync = ref.watch(linkedPatientProvider);
    final dataAsync = ref.watch(caregiverPatientDataProvider);
    final scheduleAsync = ref.watch(todayScheduleProvider);

    final isLoading = userAsync.isLoading || patientAsync.isLoading || dataAsync.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: _indigo, strokeWidth: 2))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('My Patient Dashboard', style: AppTypography.headlineMedium()),
                                  Text(
                                    patientAsync.value?['name'] as String? ?? 'No patient linked',
                                    style: AppTypography.bodySmall(color: _indigo),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: _indigo.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.people_rounded, color: _indigo, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppDimensions.lg),

                          // Connection card
                          _ConnectionCard(
                            inviteCode: userAsync.value?.inviteCode,
                            patientName: patientAsync.value?['name'] as String?,
                          ),
                          const SizedBox(height: AppDimensions.md),

                          // Adherence
                          _AdherenceCard(
                            data: dataAsync.value ?? {},
                          ),
                          const SizedBox(height: AppDimensions.md),

                          // Today's schedule
                          _TodayScheduleCard(schedule: scheduleAsync.value ?? []),
                          const SizedBox(height: AppDimensions.md),

                          // Medicine list
                          _MedicineListCard(
                            medicines: (dataAsync.value?['medicines'] as List?)
                                ?.cast<Map<String, dynamic>>() ?? [],
                          ),
                          const SizedBox(height: AppDimensions.md),

                          // Calendar
                          _CalendarCard(
                            history: (dataAsync.value?['recentHistory'] as List?)
                                ?.cast<Map<String, dynamic>>() ?? [],
                          ),
                          const SizedBox(height: AppDimensions.md),

                          // Generate report
                          GestureDetector(
                            onTap: () => _showReportSheet(context),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [_indigo, Color(0xFF6366F1)]),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(color: _indigo.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Generate Report',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1826),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: const Color(0xFF2A3A50), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Generate Report', style: AppTypography.titleLarge(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Export patient data as PDF or JSON', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () { Navigator.pop(ctx); context.push('/data-export'); },
              child: Container(
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_indigo, Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                  child: Text('Go to Export',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Connection Card ─────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final String? inviteCode;
  final String? patientName;

  const _ConnectionCard({this.inviteCode, this.patientName});

  @override
  Widget build(BuildContext context) {
    final hasPatient = patientName != null && patientName!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPatient ? const Color(0x3310B981) : _indigo.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasPatient ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasPatient ? 'Patient Connected' : 'Waiting for Patient',
                style: AppTypography.titleMedium(
                  color: hasPatient ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          if (inviteCode != null && inviteCode!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Invite Code', style: AppTypography.bodySmall(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _indigo.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      inviteCode!,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.bold,
                          color: AppColors.neonCyan, letterSpacing: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => SharePlus.instance.share(
                    ShareParams(text: 'Enter code: $inviteCode in MediFlow to connect with me'),
                  ),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _indigo.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.share_rounded, color: _indigo, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

// ── Adherence Card ──────────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AdherenceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final history = (data['recentHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final taken = history.where((h) => h['status'] == 'taken' || h['status'] == 'taken_late').length;
    final skipped = history.where((h) => h['status'] == 'skipped').length;
    final missed = history.where((h) => h['status'] == 'missed').length;
    final total = history.length;
    final pct = total == 0 ? 0.0 : (taken / total * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        children: [
          Text('30-Day Adherence', style: AppTypography.titleMedium(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          AdherenceRing(percent: pct, size: 140),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip('Taken', '$taken', const Color(0xFF10B981)),
              _statChip('Skipped', '$skipped', const Color(0xFF6366F1)),
              _statChip('Missed', '$missed', const Color(0xFFEF4444)),
            ],
          ),
          if (total == 0) ...[
            const SizedBox(height: 12),
            Text('Patient activity will appear here when doses are logged',
                style: AppTypography.bodySmall(color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Today's Schedule Card ───────────────────────────────────────────────────

class _TodayScheduleCard extends StatelessWidget {
  final List<TodaySlot> schedule;
  const _TodayScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 3, height: 18,
                decoration: BoxDecoration(color: _indigo, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text("Today's Schedule", style: AppTypography.titleMedium(color: _indigo)),
            const Spacer(),
            Text('${schedule.length} items', style: AppTypography.bodySmall(color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),
          if (schedule.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No reminders scheduled for today',
                  style: AppTypography.bodySmall(color: AppColors.textMuted))),
            )
          else
            ...schedule.map((slot) => _ScheduleRow(slot: slot)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _ScheduleRow extends StatelessWidget {
  final TodaySlot slot;
  const _ScheduleRow({required this.slot});

  String get _statusLabel {
    switch (slot.status) {
      case DoseStatus.taken: return '✅ Taken';
      case DoseStatus.takenLate: return '✅ Taken Late';
      case DoseStatus.skipped: return '⏭️ Skipped';
      case DoseStatus.missed: return '❌ Missed';
      case DoseStatus.pending: return '⏳ Pending';
    }
  }

  Color get _statusColor {
    switch (slot.status) {
      case DoseStatus.taken:
      case DoseStatus.takenLate: return const Color(0xFF10B981);
      case DoseStatus.skipped: return const Color(0xFF6366F1);
      case DoseStatus.missed: return const Color(0xFFEF4444);
      case DoseStatus.pending: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(slot.scheduledAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1100E5FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _indigo.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medication_rounded, color: _indigo, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(slot.medicineName, style: AppTypography.titleMedium(color: AppColors.textPrimary)),
              Text(timeStr, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel,
                style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Medicine List Card ──────────────────────────────────────────────────────

class _MedicineListCard extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;
  const _MedicineListCard({required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 3, height: 18,
                decoration: BoxDecoration(color: _indigo, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text('Medicines', style: AppTypography.titleMedium(color: _indigo)),
            const Spacer(),
            Text('${medicines.length}', style: AppTypography.bodySmall(color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),
          if (medicines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No medicines added yet',
                  style: AppTypography.bodySmall(color: AppColors.textMuted))),
            )
          else
            ...medicines.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              return Container(
                margin: EdgeInsets.only(bottom: i < medicines.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1420),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1100E5FF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                          color: _indigo.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.medication_rounded, color: _indigo, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m['verified_name'] ?? '—',
                            style: AppTypography.titleMedium(color: AppColors.textPrimary)),
                        if (m['form'] != null || m['strength'] != null)
                          Text(
                            '${m['form'] ?? ''}${m['strength'] != null ? ' · ${m['strength']}' : ''}',
                            style: AppTypography.bodySmall(color: AppColors.textSecondary),
                          ),
                      ]),
                    ),
                    if (m['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m['category'],
                            style: const TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

// ── Calendar Heatmap Card ───────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _CalendarCard({required this.history});

  Map<String, String> _buildCalendarData() {
    final calendar = <String, Map<String, int>>{};
    for (final h in history) {
      final raw = h['scheduled_time'] as String?;
      if (raw == null) continue;
      final d = DateTime.parse(raw).toLocal();
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      calendar.putIfAbsent(key, () => {'taken': 0, 'skipped': 0, 'missed': 0});
      final status = h['status'] as String? ?? '';
      if (status == 'taken' || status == 'taken_late') {
        calendar[key]!['taken'] = (calendar[key]!['taken'] ?? 0) + 1;
      } else if (status == 'skipped') {
        calendar[key]!['skipped'] = (calendar[key]!['skipped'] ?? 0) + 1;
      } else if (status == 'missed') {
        calendar[key]!['missed'] = (calendar[key]!['missed'] ?? 0) + 1;
      }
    }
    final result = <String, String>{};
    for (final entry in calendar.entries) {
      final m = entry.value['missed'] ?? 0;
      final s = entry.value['skipped'] ?? 0;
      final t = entry.value['taken'] ?? 0;
      if (m > 0) result[entry.key] = 'red';
      else if (s > 0) result[entry.key] = 'amber';
      else if (t > 0) result[entry.key] = 'green';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final calendarData = _buildCalendarData();
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final startWeekday = DateTime(now.year, now.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 3, height: 18,
                decoration: BoxDecoration(color: _indigo, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(DateFormat('MMMM yyyy').format(now), style: AppTypography.titleMedium(color: _indigo)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(child: Center(child: Text(d,
                    style: AppTypography.bodySmall(color: AppColors.textMuted)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1, crossAxisSpacing: 4, mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth + startWeekday - 1,
            itemBuilder: (ctx, idx) {
              if (idx < startWeekday - 1) return const SizedBox.shrink();
              final day = idx - startWeekday + 2;
              if (day > daysInMonth) return const SizedBox.shrink();
              final key =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final data = calendarData[key];
              final isToday = day == now.day;
              Color cellColor;
              if (data == 'green') cellColor = const Color(0xFF10B981);
              else if (data == 'amber') cellColor = const Color(0xFFF59E0B);
              else if (data == 'red') cellColor = const Color(0xFFEF4444);
              else cellColor = const Color(0xFF162032);
              return Container(
                decoration: BoxDecoration(
                  color: cellColor.withValues(alpha: data != null ? 0.25 : 1),
                  borderRadius: BorderRadius.circular(6),
                  border: isToday ? Border.all(color: _indigo, width: 2) : null,
                ),
                child: Center(
                  child: Text('$day',
                      style: TextStyle(
                          color: isToday ? _indigo : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF10B981), 'All taken'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFF59E0B), 'Some skipped'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFEF4444), 'Missed'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall(color: AppColors.textMuted)),
      ],
    );
  }
}
