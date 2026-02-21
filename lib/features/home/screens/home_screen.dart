import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/adherence_ring.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../../features/auth/providers/current_user_provider.dart';
import '../../medicines/providers/medicines_provider.dart';
import '../../main_tab/main_tab_screen.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _fabOpen = false;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning 👋';
    if (hour >= 12 && hour < 18) return 'Good Afternoon 🌤️';
    if (hour >= 18 && hour < 23) return 'Good Evening 🌙';
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
    'Avoid taking medicines with grapefruit juice unless approved.',
    'Check expiry dates regularly and dispose of expired medicines safely.',
    'Track your health vitals alongside medicines for best results.',
  ];

  String get _dailyTip {
    final dayIndex = DateTime.now().day % _tips.length;
    return _tips[dayIndex];
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final medicinesAsync = ref.watch(medicinesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(userAsync)),

                // ── Body ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.lg),

                        // ── Hero Adherence Ring ──────────────────
                        Center(
                          child: const AdherenceRing(percent: 0, size: 160)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Center(
                          child: Text(
                            'Start by adding your first medicine',
                            style: AppTypography.bodySmall(color: AppColors.textSecondary),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.xl),

                        // Today's Schedule
                        _SectionHeader(title: '💊 Today\'s Schedule', onSeeAll: null),
                        const SizedBox(height: AppDimensions.sm),
                        _TodayScheduleSection(),

                        const SizedBox(height: AppDimensions.lg),

                        // My Medicines
                        medicinesAsync.when(
                          data: (medicines) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                title: '🔗 My Medicines',
                                onSeeAll: medicines.isNotEmpty
                                    ? () => context.push('/home/add-medicine')
                                    : null,
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              if (medicines.isEmpty)
                                _EmptyMedicinesCard()
                              else
                                ...medicines.take(3).map(
                                      (m) => _MedicineListTile(
                                        medicine: m,
                                        onTap: () => context.push('/home/medicine/${m.id}'),
                                      ),
                                    ),
                            ],
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: AppColors.neonCyan),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppDimensions.lg),

                        // ── My Patient (caregiver only) ─────────
                        userAsync.when(
                          data: (user) {
                            if (user?.role != 'caregiver') return const SizedBox.shrink();
                            return _CaregiverPatientCard();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppDimensions.lg),

                        // Health Tip
                        _HealthTipCard(tip: _dailyTip),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Dim overlay (painted BEFORE fab for correct z-order)
            if (_fabOpen)
              GestureDetector(
                onTap: () => setState(() => _fabOpen = false),
                child: Container(color: Colors.black54),
              ),

            // FAB Speed Dial
            _FabSpeedDial(
              isOpen: _fabOpen,
              onToggle: () => setState(() => _fabOpen = !_fabOpen),
              onScan: () {
                setState(() => _fabOpen = false);
                context.push('/home/scan');
              },
              onManual: () {
                setState(() => _fabOpen = false);
                context.push('/home/add-medicine');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<User?> userAsync) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTypography.bodyMedium(color: AppColors.textSecondary)
                          .copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    userAsync.when(
                      data: (user) => Text(
                        user?.name ?? 'Welcome',
                        style: AppTypography.headlineLarge().copyWith(fontSize: 28),
                      ),
                      loading: () => Text('Welcome', style: AppTypography.headlineLarge().copyWith(fontSize: 28)),
                      error: (_, __) => Text('Welcome', style: AppTypography.headlineLarge().copyWith(fontSize: 28)),
                    ),
                  ],
                ),
                // Avatar
                userAsync.when(
                  data: (user) => GestureDetector(
                    onTap: () => ref.read(mainTabIndexProvider.notifier).setIndex(3),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [AppColors.cyanGlow],
                      ),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'M',
                          style: AppTypography.titleLarge(color: AppColors.bgPrimary),
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(width: 44, height: 44),
                  error: (_, __) => const SizedBox(width: 44, height: 44),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            // Stats Row
            _QuickStatsRow(),
          ],
        ),
      ),
    );
  }
}

// ── Quick Stats Row ──────────────────────────────────────────────────────────

class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicinesProvider);
    final count = medicinesAsync.value?.length ?? 0;

    return Row(
      children: [
        _StatChip(value: '$count', label: 'Medicines', icon: Icons.medication_rounded),
        const SizedBox(width: AppDimensions.sm),
        _StatChip(value: '0', label: 'Today', icon: Icons.check_circle_rounded),
        const SizedBox(width: AppDimensions.sm),
        _StatChip(value: '0', label: 'Reminders', icon: Icons.alarm_rounded),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatChip({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm, horizontal: AppDimensions.xs),
        child: Column(
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 18),
            const SizedBox(height: 2),
            Text(value, style: AppTypography.titleLarge()),
            Text(label, style: AppTypography.bodySmall(), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleLarge()),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('See All →', style: AppTypography.labelLarge()),
          ),
      ],
    );
  }
}

// ── Today Schedule Section ───────────────────────────────────────────────────

class _TodayScheduleSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeonCard(
      child: Column(
        children: [
          Icon(Icons.medication_liquid_rounded, color: AppColors.neonCyan, size: 40),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'No medicines scheduled today',
            style: AppTypography.titleMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Add your first medicine to get started',
            style: AppTypography.bodySmall(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: 180,
            child: _NeonMiniButton(
              label: 'Add Medicine',
              icon: Icons.add_rounded,
              onTap: () => context.push('/home/add-medicine'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _NeonMiniButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _NeonMiniButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: const [AppColors.cyanGlow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.bgPrimary, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.bodySmall(color: AppColors.bgPrimary)),
          ],
        ),
      ),
    );
  }
}

// ── Empty Medicines Card ─────────────────────────────────────────────────────

class _EmptyMedicinesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Row(
        children: [
          // Glowing emoji
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha: 0.08),
              boxShadow: const [
                BoxShadow(color: AppColors.neonCyanGlow, blurRadius: 20),
              ],
            ),
            child: const Center(child: Text('💊', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No medicines yet', style: AppTypography.titleMedium()),
                Text('Tap + to add your first medicine', style: AppTypography.bodySmall()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medicine List Tile ───────────────────────────────────────────────────────

class _MedicineListTile extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;

  const _MedicineListTile({required this.medicine, required this.onTap});

  IconData _formIcon(String? form) {
    switch (form?.toLowerCase()) {
      case 'tablet': return Icons.medication_rounded;
      case 'capsule': return Icons.medication_liquid_rounded;
      case 'liquid': case 'syrup': return Icons.local_drink_rounded;
      case 'injection': return Icons.vaccines_rounded;
      case 'cream': case 'ointment': return Icons.spa_rounded;
      case 'drops': return Icons.water_drop_rounded;
      case 'inhaler': return Icons.air_rounded;
      default: return Icons.medication_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: AppColors.glassCardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(_formIcon(medicine.form), color: AppColors.neonCyan, size: 20),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.verifiedName, style: AppTypography.titleMedium()),
                  if (medicine.form != null)
                    Text(medicine.form!, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                ],
              ),
            ),
            if (medicine.strength != null)
              Text(medicine.strength!, style: AppTypography.bodySmall(color: AppColors.neonCyan)),
            const SizedBox(width: AppDimensions.sm),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ── Health Tip Card ──────────────────────────────────────────────────────────

class _HealthTipCard extends StatelessWidget {
  final String tip;
  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: AppColors.tipGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: const [
          BoxShadow(color: Color(0x4D00C896), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💊', style: TextStyle(fontSize: 32)),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Tip', style: AppTypography.labelLarge(color: Colors.white)),
                const SizedBox(height: 4),
                Text(tip, style: AppTypography.bodySmall(color: Colors.white)),
              ],
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 16)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

// ── FAB Speed Dial ───────────────────────────────────────────────────────────

class _FabSpeedDial extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onScan;
  final VoidCallback onManual;

  const _FabSpeedDial({
    required this.isOpen,
    required this.onToggle,
    required this.onScan,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppDimensions.md,
      bottom: AppDimensions.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isOpen)
            _MiniFab(
              icon: Icons.edit_rounded,
              label: 'Add Manually',
              onTap: onManual,
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, end: 0),

          if (isOpen) const SizedBox(height: AppDimensions.sm),

          if (isOpen)
            _MiniFab(
              icon: Icons.camera_alt_rounded,
              label: 'Scan Medicine Box',
              onTap: onScan,
            ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.3, end: 0),

          if (isOpen) const SizedBox(height: AppDimensions.md),

          // Main FAB
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppDimensions.fabSize,
              height: AppDimensions.fabSize,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [AppColors.cyanGlowStrong],
              ),
              child: AnimatedRotation(
                turns: isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniFab({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: AppColors.glassCardDecoration.copyWith(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(label, style: AppTypography.bodySmall(color: AppColors.textPrimary)),
          ),
          const SizedBox(width: AppDimensions.sm),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
              boxShadow: const [AppColors.cyanGlow],
            ),
            child: Icon(icon, color: AppColors.neonCyan, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Caregiver Patient Card ─────────────────────────────────────────────────

class _CaregiverPatientCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final inviteCode = prefs.getString('caregiver_invite_code') ?? '';
    final patientName = prefs.getString('caregiver_patient_name');
    final hasPatient = patientName != null && patientName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: '👤 My Patient', onSeeAll: null),
        const SizedBox(height: AppDimensions.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1826),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1A00E5FF)),
            boxShadow: const [
              BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0, 4)),
            ],
          ),
          child: hasPatient
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Patient avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              patientName[0].toUpperCase(),
                              style: AppTypography.titleMedium(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patientName,
                                  style: AppTypography.titleMedium()),
                              Text('Patient',
                                  style: AppTypography.bodySmall(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        // Invite code badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: AppColors.neonCyan.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '🔗 $inviteCode',
                            style: AppTypography.bodySmall(
                                color: AppColors.neonCyan),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    // Adherence placeholder
                    Text('Today\'s adherence',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: 0.0,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF1A2D45),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.neonCyan),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/caregiver-dashboard'),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: const Color(0x3300E5FF)),
                            ),
                            child: Center(
                              child: Text('View Full Report →',
                                  style: AppTypography.labelLarge(
                                      color: AppColors.neonCyan)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text('No patient linked yet',
                        style: AppTypography.bodyMedium(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/invite-patient',
                              extra: {'inviteCode': inviteCode}),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF00E5FF),
                                  Color(0xFF0066FF)
                                ],
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(100)),
                            ),
                            child: Center(
                              child: Text('Share Invite Code',
                                  style: AppTypography.titleMedium(
                                      color: const Color(0xFF070B12))),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
