import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../models/task.dart';
import '../services/task_service.dart';

/// Assignments tab — real-time Firestore task list with full CRUD.
///
/// Features:
///  • Real-time updates via [userTasksProvider]
///  • Status-change popup menu (To Do / Doing / Done)
///  • Delete confirmation dialog
///  • FAB → Create Task dialog
class AssignmentsTab extends ConsumerWidget {
  const AssignmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(userTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
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
                Text('Failed to load tasks.\n$e',
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
          if (tasks.isEmpty) return const _EmptyState();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TaskCard(task: tasks[i]),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final uid = ref.read(authServiceProvider).currentUser?.uid;
              if (uid == null) return;
              await ref.read(taskServiceProvider).createTask(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    ownerId: uid,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _EmptyState
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('No tasks yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _TaskCard
// =============================================================================

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (task.status) {
      TaskStatus.todo => cs.outline,
      TaskStatus.doing => cs.primary,
      TaskStatus.done => Colors.green,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<TaskStatus>(
              initialValue: task.status,
              tooltip: 'Change status',
              onSelected: (newStatus) {
                ref.read(taskServiceProvider).updateStatus(task.id, newStatus);
              },
              itemBuilder: (_) => TaskStatus.values
                  .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              child: Chip(
                label:
                    Text(task.status.label, style: const TextStyle(fontSize: 12)),
                backgroundColor: statusColor.withValues(alpha: 0.15),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
              tooltip: 'Delete task',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(taskServiceProvider).deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
