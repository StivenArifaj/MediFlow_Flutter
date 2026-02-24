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

  String get _dailyTip => _tips[DateTime.now().day % _tips.length];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final medicinesAsync = ref.watch(medicinesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: Stack(
          children: [
            // ── Main scrollable content ──────────────────────────────────
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(userAsync)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 28),

                      // ── Hero Adherence Ring ──────────────────────────
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.12),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: const AdherenceRing(percent: 0, size: 168),
                        ).animate().fadeIn(duration: 700.ms).scale(
                              begin: const Offset(0.75, 0.75),
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Start by adding your first medicine',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF8A9BB5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Today's Schedule ─────────────────────────────
                      _SectionHeader(title: 'Today\'s Schedule'),
                      const SizedBox(height: 10),
                      _TodayScheduleSection(),

                      const SizedBox(height: 28),

                      // ── My Medicines ─────────────────────────────────
                      medicinesAsync.when(
                        data: (medicines) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              title: 'My Medicines',
                              trailing: medicines.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'See All →',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFF00E5FF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            if (medicines.isEmpty)
                              _EmptyMedicinesCard()
                            else
                              ...medicines.take(3).map((m) =>
                                  _MedicineCard(medicine: m)),
                          ],
                        ),
                        loading: () => const SizedBox(
                            height: 80,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF00E5FF), strokeWidth: 2))),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 28),

                      // ── Health Tip ───────────────────────────────────
                      _HealthTipCard(tip: _dailyTip),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),

            // ── FAB overlay ──────────────────────────────────────────────
            _buildFab(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AsyncValue<User?> userAsync) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppDimensions.md, AppDimensions.md, AppDimensions.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A9BB5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      userAsync.when(
                        data: (user) => Text(
                          user?.name ?? 'Welcome',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        loading: () => const Text('Welcome',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        error: (_, __) => const Text('Welcome',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                // Avatar
                userAsync.when(
                  data: (user) => GestureDetector(
                    onTap: () =>
                        ref.read(mainTabIndexProvider.notifier).setIndex(3),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0066FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF070B12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(width: 46, height: 46),
                  error: (_, __) => const SizedBox(width: 46, height: 46),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row
            _QuickStatsRow(),
          ],
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return Positioned(
      right: AppDimensions.md,
      bottom: AppDimensions.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mini FABs
          if (_fabOpen) ...[
            _MiniFab(
              icon: Icons.document_scanner_rounded,
              label: 'Scan Medicine Box',
              onTap: () {
                setState(() => _fabOpen = false);
                context.push('/home/scan');
              },
            ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.3, end: 0),
            const SizedBox(height: 10),
            _MiniFab(
              icon: Icons.edit_rounded,
              label: 'Add Manually',
              onTap: () {
                setState(() => _fabOpen = false);
                context.push('/home/add-medicine');
              },
            ).animate().fadeIn(duration: 150.ms).slideX(begin: 0.3, end: 0),
            const SizedBox(height: 14),
          ],

          // Main FAB
          GestureDetector(
            onTap: () => setState(() => _fabOpen = !_fabOpen),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.5),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _fabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.add_rounded,
                    color: Color(0xFF070B12), size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats Row ────────────────────────────────────────────────────────

class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicinesProvider);
    final count = medicinesAsync.value?.length ?? 0;

    return Row(
      children: [
        _StatChip(
            value: '$count',
            label: 'Medicines',
            icon: Icons.medication_rounded,
            iconColor: const Color(0xFF00E5FF)),
        const SizedBox(width: 10),
        _StatChip(
            value: '0',
            label: 'Today',
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF00C896)),
        const SizedBox(width: 10),
        _StatChip(
            value: '0',
            label: 'Reminders',
            icon: Icons.alarm_rounded,
            iconColor: const Color(0xFFFFB800)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: iconColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF8A9BB5)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left accent bar
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00E5FF),
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Today Schedule Section ─────────────────────────────────────────────────

class _TodayScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('💊', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No medicines scheduled today',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add your first medicine to get started',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.push('/home/add-medicine'),
            child: Container(
              width: 180,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_rounded, color: Color(0xFF070B12), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add Medicine',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF070B12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

// ── Empty Medicines Card ───────────────────────────────────────────────────

class _EmptyMedicinesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2840),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('➕', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'No medicines added yet',
              style: TextStyle(
                  fontSize: 14, color: Color(0xFF8A9BB5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medicine Card ──────────────────────────────────────────────────────────

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const _MedicineCard({required this.medicine});

  String get _formEmoji {
    switch ((medicine.form ?? '').toLowerCase()) {
      case 'tablet':
        return '💊';
      case 'capsule':
        return '💊';
      case 'liquid':
        return '🧪';
      case 'injection':
        return '💉';
      default:
        return '🩺';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/home/medicine/${medicine.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Form-type icon square
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2840),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _formEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name & form
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.verifiedName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medicine.form ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF3D6080)),
                      ),
                    ],
                  ),
                ),
                // Strength
                Text(
                  (medicine.strength?.isNotEmpty == true)
                      ? medicine.strength!
                      : '',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF3D6080), size: 18),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }
}

// ── Health Tip Card ────────────────────────────────────────────────────────

class _HealthTipCard extends StatelessWidget {
  final String tip;

  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF00AACC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C896).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💊', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Tip',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('✨', style: TextStyle(fontSize: 18)),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

// ── Mini FAB ───────────────────────────────────────────────────────────────

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniFab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1826),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          // Icon circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1826),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF00E5FF), size: 18),
          ),
        ],
      ),
    );
  }
}