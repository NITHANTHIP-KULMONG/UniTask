import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/dashboard_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../subjects/presentation/subjects_screen.dart';
import '../../timer/presentation/timer_screen.dart';
import 'assignments_tab.dart';

/// Index of the currently selected bottom-navigation tab.
///
/// Tabs:
///  0 — Dashboard
///  1 — Assignments
///  2 — Subjects
///  3 — Timer
///  4 — Profile
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// The main shell for regular (non-admin) users.
///
/// Provides bottom navigation with five tabs and preserves each tab's
/// state via [IndexedStack].
class UserHomePage extends ConsumerWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabIndexProvider);

    final pages = <Widget>[
      DashboardScreen(goToTasks: () {  },),
      const AssignmentsTab(),
      const SubjectsScreen(),
      const TimerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(selectedTabIndexProvider.notifier).state = i;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
