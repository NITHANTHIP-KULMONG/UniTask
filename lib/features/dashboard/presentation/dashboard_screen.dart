import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assignments/domain/assignment.dart';
import '../../assignments/domain/priority_utils.dart';
import '../../assignments/presentation/assignment_controller.dart';
import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../../timer/domain/timer_session.dart';
import '../../timer/presentation/timer_controller.dart';
import 'home_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.goToTasks,
  });

  final VoidCallback goToTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsState = ref.watch(assignmentControllerProvider);
    final subjectsState = ref.watch(subjectControllerProvider);
    final timerState = ref.watch(timerSessionsProvider);

    final subjects = subjectsState.valueOrNull ?? const <Subject>[];
    final subjectNameById = <String, String>{
      for (final s in subjects) s.id: s.name,
    };

    void goToTimer() => ref.read(selectedTabIndexProvider.notifier).state = 2;
    void goToSubjects() => ref.read(selectedTabIndexProvider.notifier).state = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(assignmentControllerProvider.notifier).load(),
          ),
        ],
      ),
      body: assignmentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(assignmentControllerProvider.notifier).load(),
        ),
        data: (items) => _DashboardBody(
          items: items,
          sessions: timerState.valueOrNull ?? const <TimerSession>[],
          subjectNameById: subjectNameById,
          subjectCount: subjects.length,
          onGoToTasks: goToTasks,
          onGoToTimer: goToTimer,
          onGoToSubjects: goToSubjects,
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.items,
    required this.sessions,
    required this.subjectNameById,
    required this.subjectCount,
    required this.onGoToTasks,
    required this.onGoToTimer,
    required this.onGoToSubjects,
  });

  final List<Assignment> items;
  final List<TimerSession> sessions;
  final Map<String, String> subjectNameById;
  final int subjectCount;
  final VoidCallback onGoToTasks;
  final VoidCallback onGoToTimer;
  final VoidCallback onGoToSubjects;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = today.add(const Duration(days: 1));

    final done = items.where((a) => a.isDone).length;
    final total = items.length;
    final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    final todayTasks = items.where((a) {
      if (a.isDone) return false;
      final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return due.isAtSameMomentAs(today);
    }).toList(growable: false);

    final upcomingCount = items.where((a) {
      if (a.isDone) return false;
      final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return due.isAfter(today);
    }).length;

    final todaySessions = sessions.where((s) {
      return !s.startAt.isBefore(today) && s.startAt.isBefore(startOfTomorrow);
    }).toList(growable: false);
    final timerTodaySeconds = todaySessions.fold<int>(
      0,
      (sum, session) => sum + (session.durationSeconds < 0 ? 0 : session.durationSeconds),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _fmtDateLong(now),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _Metric(value: '${todayTasks.length}', label: 'Today')),
                    Expanded(child: _Metric(value: '$upcomingCount', label: 'Upcoming')),
                    Expanded(child: _Metric(value: '$percent%', label: 'Completed')),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$done/$total done'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: onGoToTasks,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Assignment'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onGoToSubjects,
                      icon: const Icon(Icons.book_outlined),
                      label: const Text('Add Subject'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onGoToTasks,
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('All Assignments'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onGoToTimer,
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('Timer'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$subjectCount subjects in workspace',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Timer today: ${_fmtDuration(timerTodaySeconds)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Today tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        if (todayTasks.isEmpty)
          const _EmptyTodayCard()
        else
          ...todayTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TodayTaskTile(
                assignment: task,
                subjectName: subjectNameById[task.subjectId] ?? 'Unknown subject',
                onTap: onGoToTasks,
              ),
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _TodayTaskTile extends StatelessWidget {
  const _TodayTaskTile({
    required this.assignment,
    required this.subjectName,
    required this.onTap,
  });

  final Assignment assignment;
  final String subjectName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.assignment_outlined),
        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$subjectName • Due ${_fmtDateShort(assignment.dueDate)}'),
        trailing: _PriorityBadge(
          score: priorityScore(assignment.weightPercent, assignment.dueDate),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, bg, fg) = _styleFor(scheme, score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  (String, Color, Color) _styleFor(ColorScheme scheme, double value) {
    if (value >= 80) {
      return ('High', scheme.errorContainer, scheme.onErrorContainer);
    }
    if (value >= 50) {
      return ('Med', scheme.secondaryContainer, scheme.onSecondaryContainer);
    }
    return ('Low', scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
  }
}

class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 44,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'Nothing due today',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Great pace. Add more tasks if needed.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _fmtDateLong(DateTime d) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String _fmtDateShort(DateTime d) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String _fmtDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;

  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

