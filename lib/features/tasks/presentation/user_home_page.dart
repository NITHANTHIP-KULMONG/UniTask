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
    final iconColor = Theme.of(context).colorScheme.onSurface;
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
            icon: Icon(Icons.dashboard_outlined, color: iconColor),
            selectedIcon: Icon(Icons.dashboard, color: iconColor),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined, color: iconColor),
            selectedIcon: Icon(Icons.task_alt, color: iconColor),
            label: l10n.navTasks,
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined, color: iconColor),
            selectedIcon: Icon(Icons.timer, color: iconColor),
            label: l10n.navTimer,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: iconColor),
            selectedIcon: Icon(Icons.menu_book, color: iconColor),
            label: l10n.navSubjects,
          ),
        ],
      ),
    );
  }
}
