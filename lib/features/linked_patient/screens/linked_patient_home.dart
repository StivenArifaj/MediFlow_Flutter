import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

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

class LinkedPatientHome extends ConsumerStatefulWidget {
  const LinkedPatientHome({super.key});

  @override
  ConsumerState<LinkedPatientHome> createState() => _LinkedPatientHomeState();
}

class _LinkedPatientHomeState extends ConsumerState<LinkedPatientHome> {
  String _caregiverName = '';
  String _caregiverUid = '';
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _reminders = [];
  final Set<String> _doneToday = {}; // medicineId → status

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final cUid = prefs.getString('linked_caregiver_uid') ?? '';
    final cName = prefs.getString('linked_caregiver_name') ?? '';

    setState(() {
      _caregiverUid = cUid;
      _caregiverName = cName;
    });

    if (cUid.isEmpty || !isFirebaseReady) return;

    // Listen for medicines
    streamCaregiverMedicines(cUid).listen((meds) {
      if (mounted) setState(() => _medicines = meds);
    });

    // Listen for reminders
    streamCaregiverReminders(cUid).listen((rems) {
      if (mounted) setState(() => _reminders = rems);
    });

    // Load today's history
    final history = await getTodayHistory(cUid);
    for (final h in history) {
      _doneToday.add(h['medicineId'] ?? '');
    }
    if (mounted) setState(() {});
  }

  Future<void> _takeMedicine(Map<String, dynamic> med) async {
    final id = med['id']?.toString() ?? '';
    if (id.isEmpty || _doneToday.contains(id)) return;

    setState(() => _doneToday.add(id));

    await logDoseAction(
      caregiverUid: _caregiverUid,
      status: 'taken',
      medicineId: id,
      medicineName: med['verifiedName'] ?? med['name'] ?? 'Medicine',
    );
  }

  Future<void> _skipMedicine(Map<String, dynamic> med) async {
    final id = med['id']?.toString() ?? '';
    if (id.isEmpty || _doneToday.contains(id)) return;

    setState(() => _doneToday.add(id));

    await logDoseAction(
      caregiverUid: _caregiverUid,
      status: 'skipped',
      medicineId: id,
      medicineName: med['verifiedName'] ?? med['name'] ?? 'Medicine',
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning 🌅';
    if (h >= 12 && h < 18) return 'Good Afternoon 🌤️';
    if (h >= 18 && h < 23) return 'Good Evening 🌙';
    return 'Good Night 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final pendingMeds = _medicines
        .where((m) => !_doneToday.contains(m['id']?.toString() ?? ''))
        .toList();
    final allDone = _medicines.isNotEmpty && pendingMeds.isEmpty;

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
                child: _medicines.isEmpty
                    ? _EmptyState()
                    : allDone
                        ? _AllDoneState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.lg),
                            itemCount: pendingMeds.length,
                            itemBuilder: (ctx, i) {
                              final med = pendingMeds[i];
                              return _MedicineReminderCard(
                                medicine: med,
                                reminders: _reminders,
                                onTakeIt: () => _takeMedicine(med),
                                onSkip: () => _skipMedicine(med),
                              ).animate().fadeIn(
                                  delay: Duration(milliseconds: i * 60),
                                  duration: 300.ms);
                            },
                          ),
              ),

              // ── Bottom label ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Text(
                  'Managed by $_caregiverName',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(color: _LP.textMuted)
                      .copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Medicine Reminder Card ───────────────────────────────────────────────────

class _MedicineReminderCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final List<Map<String, dynamic>> reminders;
  final VoidCallback onTakeIt;
  final VoidCallback onSkip;

  const _MedicineReminderCard({
    required this.medicine,
    required this.reminders,
    required this.onTakeIt,
    required this.onSkip,
  });

  String _getTime() {
    final medId = medicine['id']?.toString();
    for (final r in reminders) {
      if (r['medicineId']?.toString() == medId) {
        return r['time'] ?? '';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final name = medicine['verifiedName'] ?? medicine['name'] ?? 'Medicine';
    final form = medicine['form'] ?? '';
    final strength = medicine['strength'] ?? '';
    final time = _getTime();

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
          if (time.isNotEmpty)
            Text('🕗 $time',
                style: AppTypography.bodyMedium(color: _LP.textMuted).copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(name,
              style: AppTypography.headlineMedium(color: _LP.textWhite)
                  .copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          if (form.isNotEmpty || strength.isNotEmpty)
            Text('${form.isNotEmpty ? form : ''}${strength.isNotEmpty ? ' · $strength' : ''}',
                style: AppTypography.bodyMedium(color: _LP.textMuted).copyWith(fontSize: 16)),

          const SizedBox(height: AppDimensions.md),

          // Took It button
          SizedBox(
            width: double.infinity,
            height: 68,
            child: _TookItButton(onTap: onTakeIt),
          ),

          const SizedBox(height: 10),

          // Skip button
          SizedBox(
            width: double.infinity,
            height: 68,
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
            gradient: const LinearGradient(
              colors: [Color(0xFF00C896), Color(0xFF00A878)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x3300C896), blurRadius: 16, offset: Offset(0, 4)),
            ],
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
              style: AppTypography.headlineMedium(color: _LP.textWhite)
                  .copyWith(fontSize: 22)),
          const SizedBox(height: AppDimensions.sm),
          Text('Your caregiver will set up your medicines',
              style: AppTypography.bodyMedium(color: _LP.textMuted)
                  .copyWith(fontSize: 16)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── All Done State ──────────────────────────────────────────────────────────

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
          boxShadow: const [
            BoxShadow(color: Color(0x2200C896), blurRadius: 40),
          ],
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
                style: AppTypography.bodyLarge(color: _LP.textMuted)
                    .copyWith(fontSize: 18)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
