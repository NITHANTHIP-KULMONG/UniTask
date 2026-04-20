import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final task = _resolveTask(ref);
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.taskDetailTitle)),
        body: Center(
          child: Text(l10n.taskDetailMissing),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final subjects = ref.watch(userSubjectsProvider).valueOrNull ?? const [];
    String? subjectName;
    for (final subject in subjects) {
      if (subject.id == task.subjectId) {
        subjectName = subject.name;
        break;
      }
    }

    final isDone = task.status == TaskStatus.done || task.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetailTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if ((subjectName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subjectName!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (task.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 18),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.taskDueDateLabel,
                    value: task.dueDateTime == null
                        ? l10n.taskNoDueDate
                        : DateFormat(
                            'MMM d, HH:mm',
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(task.dueDateTime!),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: l10n.taskStatusLabel,
                    value: _statusLabel(context, task),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(taskServiceProvider).updateStatus(
                    task.id,
                    isDone ? TaskStatus.todo : TaskStatus.done,
                  );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isDone ? l10n.taskMovedToTodo : l10n.taskMarkedCompleted,
                  ),
                ),
              );
            },
            icon: Icon(
              isDone ? Icons.restart_alt : Icons.check_circle_outline,
            ),
            label:
                Text(isDone ? l10n.taskMarkAsTodo : l10n.taskMarkAsCompleted),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: task),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.taskEditTitle),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error),
            ),
            onPressed: () => _confirmDelete(context, ref, task),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.taskDeleteTitle),
          ),
        ],
      ),
    );
  }

  Task? _resolveTask(WidgetRef ref) {
    final tasks = ref.watch(userTasksProvider).valueOrNull;
    if (tasks == null) return task;

    for (final t in tasks) {
      if (t.id == task.id) return t;
    }
    return null;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taskDeleteTitle),
        content: Text(l10n.taskDeleteMessage(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(taskServiceProvider).deleteTask(task.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

String _statusLabel(BuildContext context, Task task) {
  final l10n = context.l10n;
  final isDone = task.status == TaskStatus.done || task.isCompleted;
  if (isDone) return l10n.taskStatusCompleted;
  return switch (task.status) {
    TaskStatus.todo => l10n.taskStatusPending,
    TaskStatus.doing => l10n.taskStatusInProgress,
    TaskStatus.done => l10n.taskStatusCompleted,
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
