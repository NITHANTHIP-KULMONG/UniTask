import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_loading_screen.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import 'user_home_page.dart';
import 'edit_task_screen.dart';
import '../models/task.dart';
import 'new_task_dialog.dart';
import '../services/task_service.dart';
import 'task_detail_screen.dart';

class AssignmentsTab extends ConsumerStatefulWidget {
  const AssignmentsTab({super.key});

  @override
  ConsumerState<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<AssignmentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _TaskSection _section = _TaskSection.today;
  String? _subjectFilterId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _query) return;
      setState(() => _query = next);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(userTasksProvider);
    final subjects = ref.watch(userSubjectsProvider).valueOrNull ?? const [];
    final hasSubjects = subjects.isNotEmpty;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTasks)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasksFab',
        onPressed: () {
          if (!hasSubjects) {
            _showSubjectRequiredDialog(context, ref);
            return;
          }
          _showCreateDialog(context);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.dashboardActionNewTask),
      ),
      body: tasksAsync.when(
        loading: () => const AppLoadingScreen(message: 'Loading tasks...'),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text('Failed to load tasks.\n$e',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    expand: false,
                    onPressed: () => ref.invalidate(userTasksProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (tasks) {
          final subjectNameById = <String, String>{
            for (final s in subjects) s.id: s.name,
          };
          final sectionCount = _computeSectionCount(tasks);
          final visibleTasks = _applyFilters(tasks, subjectNameById);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Assignments',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tasks.length}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Search assignments',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _SubjectFilterChips(
                      subjects: subjects,
                      selectedSubjectId: _subjectFilterId,
                      onChanged: (id) => setState(() => _subjectFilterId = id),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<_TaskSection>(
                      segments: [
                        ButtonSegment<_TaskSection>(
                          value: _TaskSection.today,
                          label:
                              Text('Today ${sectionCount[_TaskSection.today]}'),
                        ),
                        ButtonSegment<_TaskSection>(
                          value: _TaskSection.upcoming,
                          label: Text(
                            'Upcoming ${sectionCount[_TaskSection.upcoming]}',
                          ),
                        ),
                        ButtonSegment<_TaskSection>(
                          value: _TaskSection.done,
                          label:
                              Text('Done ${sectionCount[_TaskSection.done]}'),
                        ),
                      ],
                      selected: {_section},
                      onSelectionChanged: (selection) {
                        setState(() => _section = selection.first);
                      },
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visibleTasks.isEmpty
                    ? _TaskSectionEmptyState(section: _section)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
                        itemCount: visibleTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _TaskCard(
                          task: visibleTasks[i],
                          subjectName:
                              subjectNameById[visibleTasks[i].subjectId] ?? '',
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<_TaskSection, int> _computeSectionCount(List<Task> tasks) {
    final out = {
      _TaskSection.today: 0,
      _TaskSection.upcoming: 0,
      _TaskSection.done: 0,
    };

    for (final task in tasks) {
      final section = _resolveSection(task);
      out[section] = out[section]! + 1;
    }

    return out;
  }

  List<Task> _applyFilters(
      List<Task> tasks, Map<String, String> subjectNameById) {
    final q = _query.toLowerCase();

    final filtered = tasks.where((task) {
      if (_resolveSection(task) != _section) return false;
      if (_subjectFilterId != null && task.subjectId != _subjectFilterId) {
        return false;
      }

      if (q.isEmpty) return true;

      final subjectName = (subjectNameById[task.subjectId] ?? '').toLowerCase();
      final dueLabel = task.dueDateTime == null
          ? ''
          : DateFormat('MMM d, HH:mm').format(task.dueDateTime!).toLowerCase();

      return task.title.toLowerCase().contains(q) ||
          task.description.toLowerCase().contains(q) ||
          subjectName.contains(q) ||
          dueLabel.contains(q);
    }).toList();

    filtered.sort((a, b) {
      if (_section == _TaskSection.done) {
        return b.updatedAt.compareTo(a.updatedAt);
      }

      final da = a.dueDateTime;
      final db = b.dueDateTime;

      if (da == null && db == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return filtered;
  }

  _TaskSection _resolveSection(Task task) {
    if (task.status == TaskStatus.done || task.isCompleted) {
      return _TaskSection.done;
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final dueDate =
        task.dueDateTime == null ? null : DateUtils.dateOnly(task.dueDateTime!);

    if (dueDate != null && dueDate.isAfter(today)) {
      return _TaskSection.upcoming;
    }

    return _TaskSection.today;
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const NewTaskDialog(),
    );
  }

  Future<void> _showSubjectRequiredDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
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
}

enum _TaskSection { today, upcoming, done }

class _SubjectFilterChips extends StatelessWidget {
  const _SubjectFilterChips({
    required this.subjects,
    required this.selectedSubjectId,
    required this.onChanged,
  });

  final List<Subject> subjects;
  final String? selectedSubjectId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ChoiceChip(
        label: const Text('All'),
        selected: selectedSubjectId == null,
        onSelected: (_) => onChanged(null),
      ),
      ...subjects.map(
        (s) => ChoiceChip(
          label: Text(s.name),
          selected: selectedSubjectId == s.id,
          onSelected: (_) => onChanged(s.id),
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }
}

class _TaskSectionEmptyState extends StatelessWidget {
  const _TaskSectionEmptyState({required this.section});

  final _TaskSection section;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (title, message, icon) = switch (section) {
      _TaskSection.today => (
          'No tasks yet',
          'Add your first task and keep your day on track.',
          Icons.check_circle_outline,
        ),
      _TaskSection.upcoming => (
          'No upcoming tasks',
          'Tasks with future due dates will appear here.',
          Icons.event_available,
        ),
      _TaskSection.done => (
          'No completed tasks yet',
          'Mark tasks as done and track your progress.',
          Icons.task_alt,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: CustomCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: cs.outline),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({
    required this.task,
    required this.subjectName,
  });

  final Task task;
  final String subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).iconTheme.color ?? cs.onSurfaceVariant;
    final done = task.status == TaskStatus.done || task.isCompleted;
    final badge = _buildDueBadge(task, cs);

    final subtitleParts = <String>[];
    if (subjectName.isNotEmpty) subtitleParts.add(subjectName);
    if (task.dueDateTime != null) {
      subtitleParts
          .add('Due ${DateFormat('MMM d, HH:mm').format(task.dueDateTime!)}');
    }
    final subtitle = subtitleParts.join(' - ');

    return CustomCard(
      onTap: () => _openDetail(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: done ? 'Mark as todo' : 'Mark as done',
            onPressed: () {
              ref.read(taskServiceProvider).updateStatus(
                    task.id,
                    done ? TaskStatus.todo : TaskStatus.done,
                  );
            },
            icon: Icon(
              done ? Icons.check_box : Icons.check_box_outline_blank,
              color: done ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: done ? cs.onSurfaceVariant : cs.error,
                        ),
                  ),
                ],
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: badge.foreground,
                  ),
                ),
                backgroundColor: badge.background,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              PopupMenuButton<_TaskAction>(
                tooltip: 'Task actions',
                iconColor: iconColor,
                onSelected: (action) {
                  if (action == _TaskAction.edit) {
                    _openEdit(context);
                    return;
                  }

                  if (action == _TaskAction.delete) {
                    _confirmDelete(context, ref);
                    return;
                  }

                  final status = switch (action) {
                    _TaskAction.todo => TaskStatus.todo,
                    _TaskAction.done => TaskStatus.done,
                    _TaskAction.edit => TaskStatus.todo,
                    _TaskAction.delete => TaskStatus.todo,
                  };
                  ref.read(taskServiceProvider).updateStatus(task.id, status);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _TaskAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _TaskAction.todo,
                    child: Text('Move to To Do'),
                  ),
                  PopupMenuItem(
                    value: _TaskAction.done,
                    child: Text('Move to Done'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: _TaskAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(task: task),
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

enum _TaskAction { edit, todo, done, delete }

class _DueBadgeData {
  const _DueBadgeData({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_DueBadgeData _buildDueBadge(Task task, ColorScheme cs) {
  final done = task.status == TaskStatus.done || task.isCompleted;
  if (done) {
    return _DueBadgeData(
      label: 'Done',
      background: cs.tertiaryContainer,
      foreground: cs.onTertiaryContainer,
    );
  }

  if (task.dueDateTime == null) {
    return _DueBadgeData(
      label: 'No date',
      background: cs.surfaceContainerHighest,
      foreground: cs.onSurfaceVariant,
    );
  }

  final today = DateUtils.dateOnly(DateTime.now());
  final due = DateUtils.dateOnly(task.dueDateTime!);

  if (due.isAtSameMomentAs(today)) {
    return _DueBadgeData(
      label: 'Today',
      background: cs.secondaryContainer,
      foreground: cs.onSecondaryContainer,
    );
  }

  if (due.isBefore(today)) {
    return _DueBadgeData(
      label: 'Overdue',
      background: cs.errorContainer,
      foreground: cs.onErrorContainer,
    );
  }

  return _DueBadgeData(
    label: 'Upcoming',
    background: cs.primaryContainer,
    foreground: cs.onPrimaryContainer,
  );
}
