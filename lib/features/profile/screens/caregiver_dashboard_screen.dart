import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';

const _indigo = Color(0xFF8B5CF6);

class CaregiverDashboardScreen extends ConsumerStatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  ConsumerState<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState
    extends ConsumerState<CaregiverDashboardScreen> {
  bool _loading = true;
  String? _inviteCode;
  String? _patientName;

  // Data from local SQLite
  int _taken = 0;
  int _skipped = 0;
  int _missed = 0;
  List<Medicine> _medicines = [];
  List<_ScheduleItem> _todaySchedule = [];
  Map<String, String> _calendarData = {}; // 'yyyy-MM-dd' -> 'green'|'amber'|'red'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Read caregiver prefs
    final prefs = await SharedPreferences.getInstance();
    _inviteCode = prefs.getString('caregiver_invite_code');
    _patientName = prefs.getString('linked_patient_name');

    // Load from local SQLite — V1: caregiver's medicines ARE the patient's medicines
    final userId = ref.read(authRepositoryProvider).currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final db = ref.read(appDatabaseProvider);

    // Get medicines
    _medicines = await db.medicinesDao.getAllMedicines(userId);

    // Get history (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final history = await db.historyDao.getHistoryForUser(userId, startDate: thirtyDaysAgo);

    int taken = 0, skipped = 0, missed = 0;
    final calendar = <String, Map<String, int>>{};

    for (final h in history) {
      if (h.status == 'taken') taken++;
      if (h.status == 'skipped') skipped++;
      if (h.status == 'missed') missed++;

      final d = h.scheduledTime;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      calendar.putIfAbsent(key, () => {'taken': 0, 'skipped': 0, 'missed': 0});
      if (h.status == 'taken') calendar[key]!['taken'] = (calendar[key]!['taken'] ?? 0) + 1;
      if (h.status == 'skipped') calendar[key]!['skipped'] = (calendar[key]!['skipped'] ?? 0) + 1;
      if (h.status == 'missed') calendar[key]!['missed'] = (calendar[key]!['missed'] ?? 0) + 1;
    }

    // Build calendar color map
    _calendarData = {};
    for (final entry in calendar.entries) {
      final m = entry.value['missed'] ?? 0;
      final s = entry.value['skipped'] ?? 0;
      final t = entry.value['taken'] ?? 0;
      if (m > 0) {
        _calendarData[entry.key] = 'red';
      } else if (s > 0) {
        _calendarData[entry.key] = 'amber';
      } else if (t > 0) {
        _calendarData[entry.key] = 'green';
      }
    }

    _taken = taken;
    _skipped = skipped;
    _missed = missed;

    // Build today's schedule
    final reminders = await db.remindersDao.getRemindersForToday(userId);
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final medMap = {for (final m in _medicines) m.id: m};

    _todaySchedule = [];
    for (final r in reminders) {
      final m = medMap[r.medicineId];
      if (m == null) continue;

      String statusLabel = '⏳ Pending';
      for (final h in history) {
        final d = h.scheduledTime;
        final hKey = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        if (hKey == todayKey && h.medicineId == m.id) {
          if (h.status == 'taken') statusLabel = '✅ Taken';
          if (h.status == 'skipped') statusLabel = '⏭️ Skipped';
          if (h.status == 'missed') statusLabel = '❌ Missed';
          break;
        }
      }

      _todaySchedule.add(_ScheduleItem(
        name: m.verifiedName,
        time: r.time,
        form: m.form ?? '',
        status: statusLabel,
      ));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: _indigo, strokeWidth: 2))
            : CustomScrollView(
                slivers: [
                  // ── Header ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('My Patient Dashboard',
                                      style: AppTypography.headlineMedium()),
                                  Text(
                                    _patientName ?? 'No patient linked',
                                    style: AppTypography.bodySmall(
                                        color: _indigo),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: _indigo.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.people_rounded,
                                  color: _indigo, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppDimensions.lg),

                          // Connection status
                          _buildConnectionCard(),
                          const SizedBox(height: AppDimensions.md),

                          // Adherence ring
                          _buildAdherenceCard(),
                          const SizedBox(height: AppDimensions.md),

                          // Today's schedule
                          _buildTodaySchedule(),
                          const SizedBox(height: AppDimensions.md),

                          // Medicine list
                          _buildMedicineList(),
                          const SizedBox(height: AppDimensions.md),

                          // Calendar heatmap
                          _buildCalendar(),
                          const SizedBox(height: AppDimensions.md),

                          // Generate report
                          GestureDetector(
                            onTap: _showReportSheet,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [_indigo, Color(0xFF6366F1)]),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                      color: _indigo.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6)),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Generate Report',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
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

  // ── Connection Card ─────────────────────────────────────────────────
  Widget _buildConnectionCard() {
    final hasPatient = _patientName != null && _patientName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: hasPatient
                ? const Color(0x3310B981)
                : _indigo.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: _indigo.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
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
                  color: hasPatient
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasPatient ? 'Patient Connected' : 'Waiting for Patient',
                style: AppTypography.titleMedium(
                    color: hasPatient
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_inviteCode != null && _inviteCode!.isNotEmpty) ...[
            Text('Invite Code',
                style: AppTypography.bodySmall(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B12),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: _indigo.withOpacity(0.3)),
                    ),
                    child: Text(
                      _inviteCode!,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonCyan,
                          letterSpacing: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final msg =
                        'Enter code: $_inviteCode in MediFlow to connect with me';
                    SharePlus.instance
                        .share(ShareParams(text: msg));
                  },
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _indigo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _indigo.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.share_rounded,
                        color: _indigo, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  // ── Adherence Card ──────────────────────────────────────────────────
  Widget _buildAdherenceCard() {
    final total = _taken + _skipped + _missed;
    final pct = total == 0 ? 0.0 : (_taken / total * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        children: [
          Text('30-Day Adherence',
              style: AppTypography.titleMedium(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          AdherenceRing(percent: pct, size: 140),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip('Taken', '$_taken', const Color(0xFF10B981)),
              _statChip('Skipped', '$_skipped', const Color(0xFF6366F1)),
              _statChip('Missed', '$_missed', const Color(0xFFEF4444)),
            ],
          ),
          if (total == 0) ...[
            const SizedBox(height: 12),
            Text('Patient activity will appear here when doses are logged',
                style: AppTypography.bodySmall(color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.bodySmall(color: AppColors.textSecondary)),
      ],
    );
  }

  // ── Today's Schedule ────────────────────────────────────────────────
  Widget _buildTodaySchedule() {
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
            Container(
              width: 3, height: 18,
              decoration: BoxDecoration(
                  color: _indigo, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text("Today's Schedule",
                style: AppTypography.titleMedium(color: _indigo)),
            const Spacer(),
            Text('${_todaySchedule.length} items',
                style: AppTypography.bodySmall(color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),
          if (_todaySchedule.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No reminders scheduled for today',
                    style: AppTypography.bodySmall(
                        color: AppColors.textMuted)),
              ),
            )
          else
            ...List.generate(_todaySchedule.length, (i) {
              final item = _todaySchedule[i];
              return Container(
                margin: EdgeInsets.only(bottom: i < _todaySchedule.length - 1 ? 8 : 0),
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
                        color: _indigo.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication_rounded,
                          color: _indigo, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: AppTypography.titleMedium(
                                    color: AppColors.textPrimary)),
                            Text(item.time,
                                style: AppTypography.bodySmall(
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(item.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item.status,
                          style: TextStyle(
                              color: _statusColor(item.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Color _statusColor(String status) {
    if (status.contains('Taken')) return const Color(0xFF10B981);
    if (status.contains('Skipped')) return const Color(0xFF6366F1);
    if (status.contains('Missed')) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  // ── Medicine List ──────────────────────────────────────────────────
  Widget _buildMedicineList() {
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
            Container(
              width: 3, height: 18,
              decoration: BoxDecoration(
                  color: _indigo, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text('Medicines',
                style: AppTypography.titleMedium(color: _indigo)),
            const Spacer(),
            Text('${_medicines.length}',
                style: AppTypography.bodySmall(color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),
          if (_medicines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No medicines added yet',
                    style: AppTypography.bodySmall(
                        color: AppColors.textMuted)),
              ),
            )
          else
            ...List.generate(_medicines.length, (i) {
              final m = _medicines[i];
              return Container(
                margin: EdgeInsets.only(bottom: i < _medicines.length - 1 ? 8 : 0),
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
                        color: _indigo.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication_rounded,
                          color: _indigo, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.verifiedName,
                                style: AppTypography.titleMedium(
                                    color: AppColors.textPrimary)),
                            if (m.form != null)
                              Text('${m.form}${m.strength != null ? ' · ${m.strength}' : ''}',
                                  style: AppTypography.bodySmall(
                                      color: AppColors.textSecondary)),
                          ]),
                    ),
                    if (m.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m.category!,
                            style: const TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  // ── Calendar Heatmap ──────────────────────────────────────────────
  Widget _buildCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon..7=Sun

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
            Container(
              width: 3, height: 18,
              decoration: BoxDecoration(
                  color: _indigo, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(DateFormat('MMMM yyyy').format(now),
                style: AppTypography.titleMedium(color: _indigo)),
          ]),
          const SizedBox(height: 12),

          // Day labels
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: AppTypography.bodySmall(
                                color: AppColors.textMuted)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Day grid
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
              final day = idx - startWeekday + 2;
              if (day > daysInMonth) return const SizedBox.shrink();

              final key =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final data = _calendarData[key];
              final isToday = day == now.day;

              Color cellColor;
              if (data == 'green') {
                cellColor = const Color(0xFF10B981);
              } else if (data == 'amber') {
                cellColor = const Color(0xFFF59E0B);
              } else if (data == 'red') {
                cellColor = const Color(0xFFEF4444);
              } else {
                cellColor = const Color(0xFF162032);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor.withOpacity(data != null ? 0.25 : 1),
                  borderRadius: BorderRadius.circular(6),
                  border: isToday
                      ? Border.all(color: _indigo, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text('$day',
                      style: TextStyle(
                          color: isToday ? _indigo : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Legend
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
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.6)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.bodySmall(color: AppColors.textMuted)),
      ],
    );
  }

  // ── Report Sheet ──────────────────────────────────────────────────
  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1826),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFF2A3A50),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('Generate Report',
                  style: AppTypography.titleLarge(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Export patient data as PDF or JSON',
                  style: AppTypography.bodySmall(
                      color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/data-export');
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_indigo, Color(0xFF6366F1)]),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text('Go to Export',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleItem {
  final String name;
  final String time;
  final String form;
  final String status;

  _ScheduleItem({
    required this.name,
    required this.time,
    required this.form,
    required this.status,
  });
}
