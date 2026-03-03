import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unitask/l10n/app_localizations.dart';

import '../../../core/l10n/l10n.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/presentation/profile_screen.dart';
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
  const DashboardScreen({super.key, required this.goToTasks});

  final VoidCallback goToTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final tasksAsync = ref.watch(userTasksProvider);
    final subjectsAsync = ref.watch(userSubjectsProvider);
    final dailyStudySecs = ref.watch(dailyStudySecondsProvider);
    final dailyPomodoros = ref.watch(dailyPomodoroCountProvider);
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;

    // Resolve display name and photo.
    final displayName = appUserAsync.whenOrNull(
          data: (u) => u?.name.isNotEmpty == true ? u!.name : u?.email,
        ) ??
        '';
    final photoUrl = appUserAsync.whenOrNull(data: (u) => u?.photoUrl);
    final firstName =
        displayName.trim().isNotEmpty ? displayName.split(' ').first : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardGreeting(firstName)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
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
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text(
                  l10n.dashboardLoadFailed('$e'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(userTasksProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (tasks) {
          // Task stats.
          final total = tasks.length;
          final todoCount =
              tasks.where((t) => t.status == TaskStatus.todo).length;
          final doingCount =
              tasks.where((t) => t.status == TaskStatus.doing).length;
          final doneCount =
              tasks.where((t) => t.status == TaskStatus.done).length;
          final progress = total == 0 ? 0.0 : doneCount / total;

          // Subject count.
          final subjectCount = subjectsAsync.valueOrNull?.length ?? 0;
          void onCreateTaskPressed() {
            if (subjectCount > 0) {
              goToTasks();
              return;
            }
            _showSubjectRequiredDialog(context, ref);
          }

          final now = DateTime.now();

          // Active tasks.
          final activeTasks =
              tasks.where((t) => t.status != TaskStatus.done).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _fmtDateLong(context, now),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              value: '$todoCount',
                              label: l10n.dashboardTodoLabel,
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: '$doingCount',
                              label: l10n.dashboardDoingLabel,
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: '$doneCount',
                              label: l10n.dashboardDoneLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          l10n.dashboardDoneProgress(doneCount, total),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardQuickActionsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: onCreateTaskPressed,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.dashboardActionNewTask),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(selectedTabIndexProvider.notifier)
                                .state = 3,
                            icon: const Icon(Icons.menu_book_outlined),
                            label: Text(l10n.dashboardActionSubjects),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(selectedTabIndexProvider.notifier)
                                .state = 2,
                            icon: const Icon(Icons.timer_outlined),
                            label: Text(l10n.dashboardActionTimer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.dashboardSummaryLine(
                          subjectCount,
                          dailyPomodoros,
                          _fmtDuration(dailyStudySecs),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.dashboardActiveTasksTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (activeTasks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: cs.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.dashboardAllCaughtUp,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dashboardNoActiveTasks,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: onCreateTaskPressed,
                          child: Text(l10n.dashboardCreateTask),
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
                    onPressed: goToTasks,
                    child: Text(l10n.dashboardViewAllTasks),
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
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
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
    final l10n = context.l10n;
    final statusColor = switch (task.status) {
      TaskStatus.todo => cs.outline,
      TaskStatus.doing => cs.primary,
      TaskStatus.done => cs.tertiary,
    };

    return Card(
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
        ),
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(
            _localizedStatusLabel(l10n, task.status),
            style: const TextStyle(fontSize: 11),
          ),
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

String _fmtDateLong(BuildContext context, DateTime d) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(d);
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

String _localizedStatusLabel(AppLocalizations l10n, TaskStatus status) {
  return switch (status) {
    TaskStatus.todo => l10n.dashboardStatusTodo,
    TaskStatus.doing => l10n.dashboardStatusDoing,
    TaskStatus.done => l10n.dashboardStatusDone,
  };
}

Future<void> _showSubjectRequiredDialog(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.subjectRequiredTitle),
      content: Text(l10n.subjectRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            ref.read(selectedTabIndexProvider.notifier).state = 3;
          },
          child: Text(l10n.subjectRequiredAction),
        ),
      ],
    ),
  );
}
