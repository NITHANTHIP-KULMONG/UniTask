import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final task = _resolveTask(ref);
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assignment Detail')),
        body: const Center(
          child: Text('Task no longer exists.'),
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
        title: const Text('Assignment Detail'),
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
                    label: 'Due date',
                    value: task.dueDate == null
                        ? 'No due date'
                        : DateFormat.yMMMd().format(task.dueDate!),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Status',
                    value: _statusLabel(task),
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
                    isDone ? 'Moved to To Do' : 'Marked as completed',
                  ),
                ),
              );
            },
            icon: Icon(
              isDone ? Icons.restart_alt : Icons.check_circle_outline,
            ),
            label: Text(isDone ? 'Mark as To Do' : 'Mark as Completed'),
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
            label: const Text('Edit Assignment'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error),
            ),
            onPressed: () => _confirmDelete(context, ref, task),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Assignment'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
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

String _statusLabel(Task task) {
  final isDone = task.status == TaskStatus.done || task.isCompleted;
  if (isDone) return 'Completed';
  return switch (task.status) {
    TaskStatus.todo => 'Pending',
    TaskStatus.doing => 'In progress',
    TaskStatus.done => 'Completed',
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
