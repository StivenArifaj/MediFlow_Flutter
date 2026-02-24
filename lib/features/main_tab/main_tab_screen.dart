import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MainTabScreen extends ConsumerWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabIndexProvider);

    const screens = [
      HomeScreen(),
      HealthScreen(),
      HistoryScreen(),
      ProfileScreen(),
    ];

    final tabs = [
      _TabItem(icon: Icons.home_rounded,      label: 'Home'),
      _TabItem(icon: Icons.favorite_rounded,   label: 'Health'),
      _TabItem(icon: Icons.history_rounded,    label: 'History'),
      _TabItem(icon: Icons.person_rounded,     label: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A1628),
          border: Border(
            top: BorderSide(color: Color(0x1A00E5FF), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final selected = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(mainTabIndexProvider.notifier).setIndex(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 24,
                            color: selected
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF3D5068),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF3D5068),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Cyan dot indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: selected ? 4 : 0,
                            height: selected ? 4 : 0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E5FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x8800E5FF),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}