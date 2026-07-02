import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/constants/app_colors.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/emergency_alert_dialog.dart';
import '../../data/services/alert_service.dart';
import '../auth/providers/current_user_provider.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class MainTabIndex extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final mainTabIndexProvider =
    NotifierProvider<MainTabIndex, int>(MainTabIndex.new);

class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen({super.key});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen> {
  sb.RealtimeChannel? _alertChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAlerts());
  }

  Future<void> _initAlerts() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null || user.role != 'caregiver' || !mounted) return;

    // Anything sent while the app was closed
    try {
      final pending = await AlertService.pendingAlertsFor(user.id);
      if (mounted && pending.isNotEmpty) {
        await showEmergencyAlert(context, pending.first);
      }
    } catch (_) {}

    // Live alerts while the app is open
    _alertChannel = supabase
        .channel('emergency-alerts-${user.id}')
        .onPostgresChanges(
          event: sb.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'emergency_alerts',
          filter: sb.PostgresChangeFilter(
            type: sb.PostgresChangeFilterType.eq,
            column: 'caregiver_id',
            value: user.id,
          ),
          callback: (payload) {
            if (mounted) showEmergencyAlert(context, payload.newRecord);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_alertChannel != null) supabase.removeChannel(_alertChannel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainTabIndexProvider);
    void setIndex(int i) =>
        ref.read(mainTabIndexProvider.notifier).setIndex(i);

    const screens = [
      HomeScreen(),
      HealthScreen(),
      HistoryScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: AppBackground(
        child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: IndexedStack(index: currentIndex, children: screens),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.darkButton,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: currentIndex == 0,
                    onTap: () => setIndex(0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Health',
                    selected: currentIndex == 1,
                    onTap: () => setIndex(1),
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: 'History',
                    selected: currentIndex == 2,
                    onTap: () => setIndex(2),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    selected: currentIndex == 3,
                    onTap: () => setIndex(3),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.darkButton
                  : Colors.white.withValues(alpha: 0.4),
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkButton,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
