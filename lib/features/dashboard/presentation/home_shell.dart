import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assignments/presentation/assignments_screen.dart';
import '../../subjects/presentation/subjects_screen.dart';
import '../../timer/presentation/timer_screen.dart';
import 'dashboard_screen.dart';

final selectedTabIndexProvider = StateProvider<int>((ref) => 1);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabIndexProvider);
    void goToTasks() => ref.read(selectedTabIndexProvider.notifier).state = 1;
    final pages = <Widget>[
      DashboardScreen(goToTasks: goToTasks),
      const AssignmentsScreen(),
      const TimerScreen(),
      const SubjectsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(selectedTabIndexProvider.notifier).state = i;
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Subjects'),
        ],
      ),
    );
  }
}
