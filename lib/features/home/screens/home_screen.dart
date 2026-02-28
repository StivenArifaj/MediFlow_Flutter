import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../../features/auth/providers/current_user_provider.dart';
import '../../medicines/providers/medicines_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<int> _actedOn = {};

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning 👋';
    if (h >= 12 && h < 18) return 'Good Afternoon 🌤️';
    if (h >= 18 && h < 23) return 'Good Evening 🌙';
    return 'Good Night 🌙';
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

  Future<void> _takeDose(Reminder r, Medicine m) async {
    if (_actedOn.contains(r.id)) return;
    setState(() => _actedOn.add(r.id));
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(authRepositoryProvider).currentUserId!;
    final now = DateTime.now();
    await db.historyDao.insertHistoryEntry(HistoryEntriesCompanion.insert(
      reminderId: r.id,
      medicineId: m.id,
      userId: userId,
      status: 'taken',
      scheduledTime: _todayAt(r.time),
      actualTime: Value(now),
      createdAt: now,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅  ${m.verifiedName} marked as taken'),
        backgroundColor: const Color(0xFF0D2820),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _skipDose(Reminder r, Medicine m) async {
    if (_actedOn.contains(r.id)) return;
    setState(() => _actedOn.add(r.id));
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(authRepositoryProvider).currentUserId!;
    final now = DateTime.now();
    await db.historyDao.insertHistoryEntry(HistoryEntriesCompanion.insert(
      reminderId: r.id,
      medicineId: m.id,
      userId: userId,
      status: 'skipped',
      scheduledTime: _todayAt(r.time),
      actualTime: Value(now),
      createdAt: now,
    ));
  }

  DateTime _todayAt(String time) {
    final p = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.tryParse(p[0]) ?? 8, int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  void _showSnooze(Reminder r, Medicine m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1826),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SnoozeSheet(
        medicineName: m.verifiedName,
        notificationId: r.notificationId ?? r.id,
        snoozeDuration: r.snoozeDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.when(
        data: (u) => u, loading: () => null, error: (_, __) => null);
    final isCaregiver = user?.role == 'caregiver';
    final userId = ref.read(authRepositoryProvider).currentUserId;
    final db = ref.read(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.5,
            colors: [Color(0xFF0D1F35), Color(0xFF070B12)],
          ),
        ),
        child: Stack(children: [
          CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.lg),

                    // ── Stats Row ──────────────────────────────
                    if (userId != null)
                      _StatsRow(userId: userId),
                    
                    if (userId != null)
                      const SizedBox(height: AppDimensions.lg),

                    // ── Adherence Ring ──────────────────────────────
                    if (userId == null)
                      const Center(child: AdherenceRing(percent: 0, size: 160))
                    else
                      FutureBuilder<List<HistoryEntry>>(
                        future: db.historyDao.getHistoryForUser(userId,
                            startDate: DateTime.now().subtract(const Duration(days: 30))),
                        builder: (ctx, snap) {
                          double pct = 0;
                          String sub = 'Add medicines to start tracking';
                          if (snap.hasData && snap.data!.isNotEmpty) {
                            final taken = snap.data!.where((e) => e.status == 'taken').length;
                            pct = taken / snap.data!.length * 100;
                            final skipped = snap.data!.where((e) => e.status == 'skipped').length;
                            sub = '$taken taken · $skipped skipped · ${snap.data!.length - taken - skipped} missed';
                          }
                          return Column(children: [
                            Center(
                              child: AdherenceRing(percent: pct, size: 160)
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(begin: const Offset(0.8, 0.8)),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Center(
                              child: Text(sub,
                                  style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                            ),
                          ]);
                        },
                      ),

                    const SizedBox(height: AppDimensions.xl),

                    // ── Today's Schedule ────────────────────────────
                    _SectionHeader(title: '💊 Today\'s Schedule'),
                    const SizedBox(height: AppDimensions.sm),

                    if (userId == null)
                      _EmptySchedule(onAdd: () => context.push('/home/add-medicine'))
                    else
                      FutureBuilder<List<Reminder>>(
                        future: db.remindersDao.getRemindersForToday(userId),
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(width: 28, height: 28,
                                  child: CircularProgressIndicator(
                                      color: AppColors.neonCyan, strokeWidth: 2)),
                              ),
                            );
                          }
                          final items = snap.data ?? [];
                          if (items.isEmpty) {
                            return _EmptySchedule(
                                onAdd: () => context.push('/home/add-medicine'));
                          }
                          return FutureBuilder<List<Medicine>>(
                            future: db.medicinesDao.getAllMedicines(userId),
                            builder: (ctx2, mSnap) {
                              final medMap = {for (final m in mSnap.data ?? []) m.id: m};
                              return Column(
                                children: items.map((r) {
                                  final m = medMap[r.medicineId];
                                  if (m == null) return const SizedBox.shrink();
                                  return _ScheduleCard(
                                    reminder: r, medicine: m,
                                    acted: _actedOn.contains(r.id),
                                    onTake: () => _takeDose(r, m),
                                    onSkip: () => _skipDose(r, m),
                                    onSnooze: () => _showSnooze(r, m),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(height: AppDimensions.lg),

                    // ── Caregiver Card ──────────────────────────────
                    if (isCaregiver) ...[
                      _SectionHeader(title: '🤝 My Patient'),
                      const SizedBox(height: AppDimensions.sm),
                      _MyPatientCard(),
                      const SizedBox(height: AppDimensions.lg),
                    ],

                    // ── My Medicines ────────────────────────────────
                    _SectionHeader(title: '🔗 My Medicines'),
                    const SizedBox(height: AppDimensions.sm),

                    ref.watch(medicinesProvider).when(
                      data: (medicines) => medicines.isEmpty
                          ? _EmptyMedicines(
                              onAdd: () => context.push('/home/add-medicine'))
                          : Column(children: [
                              ...medicines.take(5).map((m) => _MedicineCard(
                                    medicine: m,
                                    onTap: () => context.push('/home/medicine/${m.id}'),
                                  )),
                              if (medicines.length > 5)
                                TextButton(
                                  onPressed: () {},
                                  child: Text('+ ${medicines.length - 5} more',
                                      style: AppTypography.bodySmall(
                                          color: AppColors.neonCyan)),
                                ),
                            ]),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(
                                color: AppColors.neonCyan, strokeWidth: 2)),
                        ),
                      ),
                      error: (_, __) => _EmptyMedicines(
                          onAdd: () => context.push('/home/add-medicine')),
                    ),

                    const SizedBox(height: AppDimensions.lg),

                    // ── Health Tip ──────────────────────────────────
                    _HealthTipCard(tip: _dailyTip),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ]),

          // ── FAB ──────────────────────────────────────────────────
          Positioned(
            bottom: 20, right: 20,
            child: _FloatingFab(
              onScan: () => context.push('/home/scan'),
              onAdd: () => context.push('/home/add-medicine'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    final name = user?.name.split(' ').first ?? 'there';
    final initials = user?.name.isNotEmpty == true
        ? user!.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'U';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D1F35), Color(0xFF0A1628)],
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting(),
              style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.w800)),
        ]),
        Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x4000E5FF), blurRadius: 12)],
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}

// ── Schedule Card ──────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final Reminder reminder;
  final Medicine medicine;
  final bool acted;
  final VoidCallback onTake, onSkip, onSnooze;

  const _ScheduleCard({
    required this.reminder, required this.medicine,
    required this.acted, required this.onTake,
    required this.onSkip, required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: acted ? const Color(0xFF0D2820) : const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: acted ? const Color(0x3300C896) : const Color(0x2200E5FF)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: acted
                ? const Color(0xFF00C896).withOpacity(0.12)
                : AppColors.neonCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(acted ? '✅' : '💊',
                style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(medicine.verifiedName,
                style: AppTypography.titleMedium(
                    color: acted ? AppColors.textSecondary : AppColors.textPrimary)),
            Text(reminder.time,
                style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          ]),
        ),
        if (!acted) ...[
          _ActionBtn(label: 'Take', color: const Color(0xFF00C896), onTap: onTake),
          const SizedBox(width: 6),
          _ActionBtn(label: 'Skip', color: const Color(0xFFFF6B6B), onTap: onSkip),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onSnooze,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF162032),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.snooze_rounded,
                  color: AppColors.textSecondary, size: 16),
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Done',
                style: TextStyle(color: Color(0xFF00C896),
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ]),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
          width: 36, height: 4,
          decoration: BoxDecoration(
              color: const Color(0xFF2A3A50),
              borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Snooze $medicineName',
            style: AppTypography.titleLarge(color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        Row(
          children: options.map((min) => Expanded(
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
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x2200E5FF)),
                ),
                child: Center(
                  child: Text('${min}m',
                      style: AppTypography.titleMedium(color: AppColors.neonCyan)),
                ),
              ),
            ),
          )).toList(),
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

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF8B5CF6), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('My Patient', style: AppTypography.titleMedium(color: AppColors.textPrimary)),
                    Text(
                      hasPatient ? patientName : 'No patient linked yet',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () => context.push('/caregiver-dashboard'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                    ),
                    child: Text(hasPatient ? 'View Report →' : 'Dashboard →',
                        style: const TextStyle(color: Color(0xFF8B5CF6),
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
              if (inviteCode != null && inviteCode.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.vpn_key_rounded, color: AppColors.neonCyan, size: 14),
                    const SizedBox(width: 8),
                    Text('Invite Code: ', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                    Text(inviteCode, style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppColors.neonCyan, letterSpacing: 2,
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
    final prefs = await SharedPreferences.getInstance();
    return {
      'patientName': prefs.getString('linked_patient_name'),
      'inviteCode': prefs.getString('caregiver_invite_code'),
    };
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.replaceAll('💊 ', '').replaceAll('🤝 ', '').replaceAll('🔗 ', ''),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00E5FF),
          ),
        ),
      ],
    );
  }
}

// ── Empty Schedule ─────────────────────────────────────────────────────────────

class _EmptySchedule extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySchedule({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppColors.neonCardDecoration,
      child: Column(children: [
        const Icon(Icons.calendar_today_rounded, size: 40, color: Color(0xFF334155)),
        const SizedBox(height: 12),
        const Text('Nothing scheduled for today',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Add a medicine and set a reminder to see it here',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5)),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0088FF)]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Add Medicine', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Empty Medicines ────────────────────────────────────────────────────────────

class _EmptyMedicines extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMedicines({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.neonCardDecoration,
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withOpacity(0.08),
          ),
          child: const Center(child: Text('💊', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No medicines yet',
                style: AppTypography.titleMedium(color: AppColors.textPrimary)),
            Text('Tap + to add your first medicine',
                style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  final int userId;
  const _StatsRow({required this.userId});

  int _calculateStreak(List<HistoryEntry> allEntries) {
    if (allEntries.isEmpty) return 0;
    final byDay = <String, List<HistoryEntry>>{};
    for (final e in allEntries) {
      final key = '${e.scheduledTime.year}-${e.scheduledTime.month}-${e.scheduledTime.day}';
      byDay.putIfAbsent(key, () => []).add(e);
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
      if (dayEntries.any((e) => e.status == 'missed')) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(appDatabaseProvider);
    
    return FutureBuilder(
      future: Future.wait([
        db.medicinesDao.getAllMedicines(userId),
        db.remindersDao.getRemindersForToday(userId),
        db.historyDao.getHistoryForUser(userId),
      ]),
      builder: (ctx, snap) {
        int meds = 0, today = 0, streak = 0;
        if (snap.hasData) {
          meds = (snap.data![0] as List<Medicine>).length;
          today = (snap.data![1] as List<Reminder>).length;
          streak = _calculateStreak(snap.data![2] as List<HistoryEntry>);
        }
        return Row(
          children: [
            _StatChip(
              icon: Icons.medication_rounded,
              iconColor: const Color(0xFF00E5FF),
              value: '$meds',
              label: 'Medicines',
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.calendar_today_rounded,
              iconColor: const Color(0xFF00E5FF),
              value: '$today',
              label: 'Today',
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFFFB800),
              value: '$streak',
              label: 'Streak',
            ),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1A00E5FF)),
          boxShadow: const [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
          ],
        ),
      ),
    );
  }
}

// ── Medicine Card ──────────────────────────────────────────────────────────────

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  const _MedicineCard({required this.medicine, required this.onTap});

  IconData _icon() {
    final f = medicine.form?.toLowerCase() ?? '';
    if (f.contains('capsule')) return Icons.medication_rounded;
    if (f.contains('liquid') || f.contains('syrup')) return Icons.water_drop_rounded;
    if (f.contains('inject')) return Icons.colorize_rounded;
    return Icons.medication_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A00E5FF)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(), color: AppColors.neonCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medicine.verifiedName,
                  style: AppTypography.titleMedium(color: AppColors.textPrimary)),
              if (medicine.form != null)
                Text(medicine.form!,
                    style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            ]),
          ),
          if (medicine.strength != null)
            Text(medicine.strength!,
                style: AppTypography.bodySmall(color: AppColors.neonCyan)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
        ]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.tipGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💊', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Health Tip',
                  style: TextStyle(color: Color(0xFF08090F),
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              const Text('✨', style: TextStyle(fontSize: 16)),
            ]),
            const SizedBox(height: 4),
            Text(tip,
                style: const TextStyle(color: Color(0xFF08090F),
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

// ── Floating FAB ───────────────────────────────────────────────────────────────

class _FloatingFab extends StatefulWidget {
  final VoidCallback onScan, onAdd;
  const _FloatingFab({required this.onScan, required this.onAdd});

  @override
  State<_FloatingFab> createState() => _FloatingFabState();
}

class _FloatingFabState extends State<_FloatingFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween(begin: 0.0, end: 0.125).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _MiniOption(icon: Icons.document_scanner_rounded, label: 'Scan Box',
              onTap: () { _toggle(); widget.onScan(); }),
          const SizedBox(height: 8),
          _MiniOption(icon: Icons.add_rounded, label: 'Add Manually',
              onTap: () { _toggle(); widget.onAdd(); }),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _rotate,
            builder: (_, __) => Transform.rotate(
              angle: _rotate.value * 2 * pi,
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x4000E5FF), blurRadius: 16)],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1826),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x2200E5FF)),
          ),
          child: Text(label, style: AppTypography.bodySmall(color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1826),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x2200E5FF)),
          ),
          child: Icon(icon, color: AppColors.neonCyan, size: 18),
        ),
      ]),
    );
  }
}