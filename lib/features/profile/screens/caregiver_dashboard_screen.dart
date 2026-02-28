import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
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
  String? _caregiverUid;

  // Patient data from Firestore
  int _taken = 0;
  int _skipped = 0;
  int _missed = 0;
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _todaySchedule = [];
  Map<String, String> _calendarData = {}; // 'yyyy-MM-dd' -> 'green'|'amber'|'red'|'gray'

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _loadLocalData() {
    final prefs = ref.read(sharedPreferencesProvider);
    _inviteCode = prefs.getString('caregiver_invite_code');
    _patientName = prefs.getString('linked_patient_name');
    _caregiverUid = prefs.getString('firebase_uid');

    if (_caregiverUid != null) {
      _loadFirestoreData();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadFirestoreData() async {
    try {
      final fs = FirebaseFirestore.instance;
      final basePath = 'caregivers/$_caregiverUid';

      // Load medicines
      final medsSnap = await fs.collection('$basePath/medicines').get();
      _medicines = medsSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();

      // Load history (last 30 days)
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));
      final histSnap = await fs
          .collection('$basePath/history')
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      int taken = 0, skipped = 0, missed = 0;
      final calendar = <String, Map<String, int>>{};

      for (final doc in histSnap.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        if (status == 'taken') taken++;
        if (status == 'skipped') skipped++;
        if (status == 'missed') missed++;

        final ts = data['scheduledTime'];
        if (ts is Timestamp) {
          final d = ts.toDate();
          final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          calendar.putIfAbsent(key, () => {'taken': 0, 'skipped': 0, 'missed': 0});
          if (status == 'taken') calendar[key]!['taken'] = (calendar[key]!['taken'] ?? 0) + 1;
          if (status == 'skipped') calendar[key]!['skipped'] = (calendar[key]!['skipped'] ?? 0) + 1;
          if (status == 'missed') calendar[key]!['missed'] = (calendar[key]!['missed'] ?? 0) + 1;
        }
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
      _todaySchedule = [];
      final now = DateTime.now();
      final remindersSnap = await fs.collection('$basePath/reminders').get();
      for (final doc in remindersSnap.docs) {
        final data = doc.data();
        final medId = data['medicineId'];
        final medName = _medicines
                .firstWhere((m) => m['id'] == medId,
                    orElse: () => {'verifiedName': 'Medicine'})['verifiedName'] ??
            'Medicine';
        final time = data['time'] as String? ?? '08:00';
        final form = data['form'] as String? ?? '';

        // Check today's history for this reminder
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        String statusLabel = '⏳ Pending';
        for (final h in histSnap.docs) {
          final hData = h.data();
          final ts = hData['scheduledTime'];
          if (ts is Timestamp) {
            final d = ts.toDate();
            final hKey =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            if (hKey == todayKey && hData['medicineId'] == medId) {
              final s = hData['status'] ?? '';
              if (s == 'taken') statusLabel = '✅ Taken';
              if (s == 'skipped') statusLabel = '⏭️ Skipped';
              if (s == 'missed') statusLabel = '❌ Missed';
              break;
            }
          }
        }

        _todaySchedule.add({
          'name': medName,
          'time': time,
          'form': form,
          'status': statusLabel,
        });
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    }
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _indigo.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                                border: Border.all(
                                    color: _indigo.withOpacity(0.4)),
                              ),
                              child: const Text('🤝 Caregiver',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _indigo)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Connection Status ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _buildConnectionCard(),
                    ).animate().fadeIn(duration: 400.ms),
                  ),

                  // ── Adherence Ring ────────────────────────────
                  if (_caregiverUid != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildAdherenceCard(),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    ),

                  // ── Today's Schedule ──────────────────────────
                  if (_todaySchedule.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildTodaySchedule(),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ),

                  // ── Medicine List ─────────────────────────────
                  if (_medicines.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildMedicineList(),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    ),

                  // ── Calendar Heatmap ──────────────────────────
                  if (_calendarData.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildCalendar(),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    ),

                  // ── No Firestore data message ─────────────────
                  if (_caregiverUid == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.wifi_off_rounded,
                                  color: AppColors.warning, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'Connect to internet to view patient data',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium(
                                    color: AppColors.warning),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Generate Report button ────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 24, 16, 100),
                      child: GestureDetector(
                        onTap: _showReportSheet,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_indigo, Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: _indigo.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text('Generate Patient Report',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Connection Status Card ────────────────────────────────────────────────

  Widget _buildConnectionCard() {
    final hasCode = _inviteCode != null && _inviteCode!.isNotEmpty;
    final hasPatient = _patientName != null && _patientName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _indigo.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _indigo.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(hasPatient ? Icons.link_rounded : Icons.link_off_rounded,
                  color: hasPatient ? AppColors.success : AppColors.warning,
                  size: 20),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasPatient
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: hasPatient
                          ? AppColors.success
                          : AppColors.warning),
                ),
                child: Text(
                  hasPatient ? '🔗 Linked' : '⚠️ Not linked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        hasPatient ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          if (hasCode) ...[
            const SizedBox(height: 14),
            Text('Invite Code',
                style: AppTypography.bodySmall(
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              _inviteCode!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _indigo,
                letterSpacing: 6,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (hasPatient) ...[
            const SizedBox(height: 10),
            Text('Patient: $_patientName',
                style: AppTypography.bodyMedium(color: Colors.white)),
          ],
          if (!hasPatient) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                if (hasCode) {
                  SharePlus.instance.share(ShareParams(
                    text:
                        "Hi! I've set up MediFlow to manage your medicines. Download MediFlow and enter this code: $_inviteCode to get started.",
                  ));
                }
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_indigo, Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                  child: Text('Share Invite Code',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Adherence Card ────────────────────────────────────────────────────────

  Widget _buildAdherenceCard() {
    final total = _taken + _skipped + _missed;
    final pct = total > 0 ? (_taken / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _indigo.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: _indigo.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Patient Adherence',
              style: AppTypography.titleMedium(color: _indigo)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _indigo.withOpacity(0.15),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: AdherenceRing(
              percent: pct.toDouble(),
              size: 140,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$_taken taken · $_skipped skipped · $_missed missed',
            style: AppTypography.bodySmall(color: AppColors.textSecondary),
          ),
          Text('Last 30 days',
              style: AppTypography.bodySmall(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ── Today's Schedule ──────────────────────────────────────────────────────

  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📅 Patient\'s Schedule Today',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 14),
          for (final item in _todaySchedule) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1A00E5FF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['time'] ?? '',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _indigo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        if ((item['form'] ?? '').isNotEmpty)
                          Text(item['form'],
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8A9BB5))),
                      ],
                    ),
                  ),
                  Text(
                    item['status'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (item['status'] ?? '').contains('Taken')
                          ? AppColors.success
                          : (item['status'] ?? '').contains('Missed')
                              ? AppColors.error
                              : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Medicine List ─────────────────────────────────────────────────────────

  Widget _buildMedicineList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💊 Patient\'s Medicines (${_medicines.length})',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 14),
          for (final med in _medicines) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _indigo.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: _indigo, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med['verifiedName'] ?? 'Unknown',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        if (med['form'] != null || med['strength'] != null)
                          Text(
                            [med['form'], med['strength']]
                                .where((e) => e != null)
                                .join(' · '),
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF8A9BB5)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Calendar Heatmap ──────────────────────────────────────────────────────

  Widget _buildCalendar() {
    final now = DateTime.now();
    final days = <DateTime>[];
    for (int i = 29; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A00E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Adherence Calendar (30 Days)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: days.map((d) {
              final key =
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final status = _calendarData[key];
              Color color;
              switch (status) {
                case 'green':
                  color = AppColors.success;
                  break;
                case 'amber':
                  color = AppColors.warning;
                  break;
                case 'red':
                  color = AppColors.error;
                  break;
                default:
                  color = const Color(0xFF1A2840);
              }
              return Tooltip(
                message: '${d.day}/${d.month} — ${status ?? 'No data'}',
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(status != null ? 0.7 : 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color.withOpacity(status != null ? 0.9 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color:
                            status != null ? Colors.white : const Color(0xFF4A5A72),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.success, 'All Taken'),
              const SizedBox(width: 12),
              _legendDot(AppColors.warning, 'Some Skipped'),
              const SizedBox(width: 12),
              _legendDot(AppColors.error, 'Some Missed'),
              const SizedBox(width: 12),
              _legendDot(const Color(0xFF1A2840), 'No Data'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF8A9BB5))),
      ],
    );
  }

  // ── Report Sheet ──────────────────────────────────────────────────────────

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                color: _indigo, size: 48),
            const SizedBox(height: 16),
            Text('Patient Report', style: AppTypography.headlineMedium()),
            const SizedBox(height: 8),
            Text(
              'Generate a PDF report with your patient\'s medication adherence data for doctor visits.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can also export JSON data from Profile > Export & Share Data',
                      style: AppTypography.bodySmall(
                          color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                // Navigate to profile export
                context.push('/data-export');
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_indigo, Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                  child: Text('Export Data',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
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
