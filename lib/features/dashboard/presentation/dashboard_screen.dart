import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../../tasks/models/task.dart';
import '../../tasks/presentation/user_home_page.dart';
import '../../tasks/services/task_service.dart';
import '../../timer/services/study_session_service.dart';

/// Dashboard tab — overview of tasks, study time, and quick actions.
///
/// Shows:
///  • Greeting with avatar in the AppBar
///  • Task summary (to do / doing / done) with progress bar
///  • Quick-action buttons to navigate other tabs
///  • Timer time today
///  • Active (non-done) tasks list with "View all" link
///  • Empty state CTA when no active tasks exist
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required void Function() goToTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final tasksAsync = ref.watch(userTasksProvider);
    final subjectsAsync = ref.watch(userSubjectsProvider);
    final dailyStudySecs = ref.watch(dailyStudySecondsProvider);
    final dailyPomodoros = ref.watch(dailyPomodoroCountProvider);

    // Resolve display name and photo.
    final displayName = appUserAsync.whenOrNull(
          data: (u) => u?.name.isNotEmpty == true ? u!.name : u?.email,
        ) ??
        '';
    final photoUrl = appUserAsync.whenOrNull(data: (u) => u?.photoUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${displayName.split(' ').first}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      (displayName.isNotEmpty ? displayName[0] : '?')
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load dashboard.\n$e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(userTasksProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (tasks) {
          // ── Task stats ──
          final total = tasks.length;
          final todoCount =
              tasks.where((t) => t.status == TaskStatus.todo).length;
          final doingCount =
              tasks.where((t) => t.status == TaskStatus.doing).length;
          final doneCount =
              tasks.where((t) => t.status == TaskStatus.done).length;
          final progress = total == 0 ? 0.0 : doneCount / total;

          // ── Subject count ──
          final subjectCount = subjectsAsync.valueOrNull?.length ?? 0;

          final now = DateTime.now();

          // ── Active tasks ──
          final activeTasks =
              tasks.where((t) => t.status != TaskStatus.done).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date
              Text(
                _fmtDateLong(now),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),

              // ── Stats card ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child:
                                  _Stat(value: '$todoCount', label: 'To Do')),
                          Expanded(
                              child:
                                  _Stat(value: '$doingCount', label: 'Doing')),
                          Expanded(
                              child:
                                  _Stat(value: '$doneCount', label: 'Done')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('$doneCount / $total done',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Quick actions card ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => ref
                                .read(selectedTabIndexProvider.notifier)
                                .state = 1,
                            icon: const Icon(Icons.add),
                            label: const Text('New Task'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(selectedTabIndexProvider.notifier)
                                .state = 2,
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text('Subjects'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(selectedTabIndexProvider.notifier)
                                .state = 3,
                            icon: const Icon(Icons.timer_outlined),
                            label: const Text('Timer'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$subjectCount subjects • $dailyPomodoros pomodoros • ${_fmtDuration(dailyStudySecs)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Active tasks section ──
              Text('Active Tasks',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              if (activeTasks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 12),
                        Text('All caught up!',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'No active tasks. Create one to get started.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref
                              .read(selectedTabIndexProvider.notifier)
                              .state = 1,
                          child: const Text('Create Task'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...activeTasks.take(5).map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DashboardTaskTile(task: task),
                      ),
                    ),

              if (activeTasks.length > 5) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => ref
                        .read(selectedTabIndexProvider.notifier)
                        .state = 1,
                    child: const Text('View all tasks'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// Internal widgets
// =============================================================================

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _DashboardTaskTile extends StatelessWidget {
  const _DashboardTaskTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (task.status) {
      TaskStatus.todo => cs.outline,
      TaskStatus.doing => cs.primary,
      TaskStatus.done => Colors.green,
    };

    return Card(
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        title:
            Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(task.status.label,
              style: const TextStyle(fontSize: 11)),
          backgroundColor: statusColor.withValues(alpha: 0.15),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

// =============================================================================
// Formatters
// =============================================================================

String _fmtDateLong(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String _fmtDuration(int totalSeconds) {
  final safe = totalSeconds.clamp(0, 999999);
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

