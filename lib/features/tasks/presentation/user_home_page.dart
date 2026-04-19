import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../subjects/presentation/subjects_screen.dart';
import '../../timer/presentation/timer_screen.dart';
import 'assignments_tab.dart';

/// Index of the currently selected bottom-navigation tab.
///
/// Tabs:
///  0 — Dashboard
///  1 — Tasks
///  2 — Timer
///  3 — Subjects
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// The main shell for regular (non-admin) users.
///
/// Provides bottom navigation with four tabs and preserves each tab's
/// state via [IndexedStack].
class UserHomePage extends ConsumerWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabIndexProvider);
    final l10n = context.l10n;
    void goToTasks() => ref.read(selectedTabIndexProvider.notifier).state = 1;

    final pages = <Widget>[
      DashboardScreen(goToTasks: goToTasks),
      const AssignmentsTab(),
      const TimerScreen(),
      const SubjectsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(selectedTabIndexProvider.notifier).state = i;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l10n.navTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navTimer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navSubjects,
          ),
        ],
      ),
    );
  }
}
