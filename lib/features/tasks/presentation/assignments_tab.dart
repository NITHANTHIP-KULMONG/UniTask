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

enum TaskSection { today, upcoming, done }

final taskSectionProvider =
    StateProvider<TaskSection>((ref) => TaskSection.today);

class AssignmentsTab extends ConsumerStatefulWidget {
  const AssignmentsTab({super.key});

  @override
  ConsumerState<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<AssignmentsTab> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _SwipeActionType> _inFlightSwipeActions =
      <String, _SwipeActionType>{};
  String _query = '';
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
    final section = ref.watch(taskSectionProvider);
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
        loading: () => AppLoadingScreen(message: l10n.tasksLoading),
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
                  Text(l10n.tasksLoadFailed('$e'), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: l10n.commonRetry,
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
          _scheduleResolvedActionCleanup(tasks);

          final localeTag = Localizations.localeOf(context).toLanguageTag();
          final subjectNameById = <String, String>{
            for (final s in subjects) s.id: s.name,
          };
          final effectiveTasks = _buildEffectiveTasks(tasks);
          final sectionCount = _computeSectionCount(effectiveTasks);
          final visibleTasks =
              _applyFilters(effectiveTasks, subjectNameById, section, localeTag);

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
                          l10n.tasksAssignmentsTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${effectiveTasks.length}',
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
                      hintText: l10n.tasksAssignmentsTitle,
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
                    SegmentedButton<TaskSection>(
                      segments: [
                        ButtonSegment<TaskSection>(
                          value: TaskSection.today,
                          label: Text(l10n.tasksSectionToday(
                              sectionCount[TaskSection.today] ?? 0)),
                        ),
                        ButtonSegment<TaskSection>(
                          value: TaskSection.upcoming,
                          label: Text(l10n.tasksSectionUpcoming(
                              sectionCount[TaskSection.upcoming] ?? 0)),
                        ),
                        ButtonSegment<TaskSection>(
                          value: TaskSection.done,
                          label: Text(l10n.tasksSectionDone(
                              sectionCount[TaskSection.done] ?? 0)),
                        ),
                      ],
                      selected: {section},
                      onSelectionChanged: (selection) {
                        ref.read(taskSectionProvider.notifier).state =
                            selection.first;
                      },
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.refresh(userTasksProvider.future),
                  child: visibleTasks.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(top: 60),
                          children: [_TaskSectionEmptyState(section: section)],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
                          itemCount: visibleTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _TaskCard(
                            task: visibleTasks[i],
                            subjectName:
                                subjectNameById[visibleTasks[i].subjectId] ??
                                    '',
                            localeTag: localeTag,
                            onDeleteSwiped: (task) =>
                                _handleTaskDeleteSwipe(context, task),
                            onCompleteSwiped: (task) =>
                                _handleTaskCompleteSwipe(context, task),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Task> _buildEffectiveTasks(List<Task> tasks) {
    final effective = <Task>[];

    for (final task in tasks) {
      final inFlightAction = _inFlightSwipeActions[task.id];
      if (inFlightAction == null) {
        effective.add(task);
        continue;
      }

      switch (inFlightAction) {
        case _SwipeActionType.delete:
          continue;
        case _SwipeActionType.complete:
          effective.add(
            task.copyWith(
              status: TaskStatus.done,
              isCompleted: true,
              updatedAt: DateTime.now(),
            ),
          );
      }
    }

    return effective;
  }

  void _scheduleResolvedActionCleanup(List<Task> tasks) {
    if (_inFlightSwipeActions.isEmpty) return;

    final taskById = <String, Task>{for (final task in tasks) task.id: task};
    final resolvedTaskIds = <String>[];

    _inFlightSwipeActions.forEach((taskId, action) {
      final task = taskById[taskId];
      final isResolved = switch (action) {
        _SwipeActionType.delete => task == null,
        _SwipeActionType.complete =>
          task != null && (task.status == TaskStatus.done || task.isCompleted),
      };

      if (isResolved) {
        resolvedTaskIds.add(taskId);
      }
    });

    if (resolvedTaskIds.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        for (final taskId in resolvedTaskIds) {
          _inFlightSwipeActions.remove(taskId);
        }
      });
    });
  }

  Map<TaskSection, int> _computeSectionCount(List<Task> tasks) {
    final out = {
      TaskSection.today: 0,
      TaskSection.upcoming: 0,
      TaskSection.done: 0,
    };

    for (final task in tasks) {
      final section = _resolveSection(task);
      out[section] = out[section]! + 1;
    }

    return out;
  }

  List<Task> _applyFilters(
    List<Task> tasks,
    Map<String, String> subjectNameById,
    TaskSection currentSection,
    String localeTag,
  ) {
    final q = _query.toLowerCase();

    final filtered = tasks.where((task) {
      if (_resolveSection(task) != currentSection) return false;
      if (_subjectFilterId != null && task.subjectId != _subjectFilterId) {
        return false;
      }

      if (q.isEmpty) return true;

      final subjectName = (subjectNameById[task.subjectId] ?? '').toLowerCase();
      final dueLabel = task.dueDateTime == null
          ? ''
          : DateFormat('MMM d, HH:mm', localeTag)
              .format(task.dueDateTime!)
              .toLowerCase();

      return task.title.toLowerCase().contains(q) ||
          task.description.toLowerCase().contains(q) ||
          subjectName.contains(q) ||
          dueLabel.contains(q);
    }).toList();

    filtered.sort((a, b) {
      if (currentSection == TaskSection.done) {
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

  TaskSection _resolveSection(Task task) {
    if (task.status == TaskStatus.done || task.isCompleted) {
      return TaskSection.done;
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final dueDate =
        task.dueDateTime == null ? null : DateUtils.dateOnly(task.dueDateTime!);

    if (dueDate != null && dueDate.isAfter(today)) {
      return TaskSection.upcoming;
    }

    return TaskSection.today;
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NewTaskDialog(),
    );
  }

  void _handleTaskDeleteSwipe(BuildContext context, Task task) {
    if (_inFlightSwipeActions.containsKey(task.id)) return;

    setState(() {
      _inFlightSwipeActions[task.id] = _SwipeActionType.delete;
    });

    _runSwipeAction(
      taskId: task.id,
      actionType: _SwipeActionType.delete,
      request: () => ref.read(taskServiceProvider).deleteTask(task.id),
    );
  }

  void _handleTaskCompleteSwipe(BuildContext context, Task task) {
    if (_inFlightSwipeActions.containsKey(task.id)) return;

    final done = task.status == TaskStatus.done || task.isCompleted;
    if (done) return;

    setState(() {
      _inFlightSwipeActions[task.id] = _SwipeActionType.complete;
    });

    _runSwipeAction(
      taskId: task.id,
      actionType: _SwipeActionType.complete,
      request: () =>
          ref.read(taskServiceProvider).updateStatus(task.id, TaskStatus.done),
    );
  }

  Future<void> _runSwipeAction({
    required String taskId,
    required _SwipeActionType actionType,
    required Future<void> Function() request,
  }) async {
    try {
      await request();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (_inFlightSwipeActions[taskId] == actionType) {
          _inFlightSwipeActions.remove(taskId);
        }
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(context.l10n.taskSaveFailed('$e')),
          ),
        );
    }
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
        label: Text(context.l10n.tasksFilterAll),
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

  final TaskSection section;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (title, message, icon) = switch (section) {
      TaskSection.today => (
          context.l10n.tasksEmptyTitle,
          context.l10n.tasksEmptySubtitle,
          Icons.check_circle_outline,
        ),
      TaskSection.upcoming => (
          context.l10n.tasksEmptyTitle,
          context.l10n.tasksEmptySubtitle,
          Icons.event_available,
        ),
      TaskSection.done => (
          context.l10n.tasksEmptyTitle,
          context.l10n.tasksEmptySubtitle,
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
    required this.localeTag,
    required this.onDeleteSwiped,
    required this.onCompleteSwiped,
  });

  final Task task;
  final String subjectName;
  final String localeTag;
  final ValueChanged<Task> onDeleteSwiped;
  final ValueChanged<Task> onCompleteSwiped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).iconTheme.color ?? cs.onSurfaceVariant;
    final done = task.status == TaskStatus.done || task.isCompleted;
    final badge = _buildDueBadge(context, task, cs);

    final subtitleParts = <String>[];
    if (subjectName.isNotEmpty) subtitleParts.add(subjectName);
    if (task.dueDateTime != null) {
      subtitleParts.add(context.l10n.taskSubtitleDue(
          DateFormat('MMM d, HH:mm', localeTag).format(task.dueDateTime!)));
    }
    final subtitle = subtitleParts.join(' - ');

    return Dismissible(
      key: ValueKey(task.id),
      direction: done ? DismissDirection.endToStart : DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.check, color: cs.onPrimary),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: cs.onError),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDeleteSwiped(task);
          return;
        }

        onCompleteSwiped(task);
      },
      child: CustomCard(
        onTap: () => _openDetail(context),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: done
                  ? context.l10n.taskTooltipMarkTodo
                  : context.l10n.taskTooltipMarkDone,
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
                  tooltip: context.l10n.taskTooltipActions,
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
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _TaskAction.edit,
                      child: Text(context.l10n.taskActionEdit),
                    ),
                    PopupMenuItem(
                      value: _TaskAction.todo,
                      child: Text(context.l10n.taskActionMoveTodo),
                    ),
                    PopupMenuItem(
                      value: _TaskAction.done,
                      child: Text(context.l10n.taskActionMoveDone),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: _TaskAction.delete,
                      child: Text(context.l10n.commonDelete),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
        title: Text(context.l10n.taskDeleteTitle),
        content: Text(context.l10n.taskDeleteMessage(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(taskServiceProvider).deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}

enum _SwipeActionType { delete, complete }

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

_DueBadgeData _buildDueBadge(BuildContext context, Task task, ColorScheme cs) {
  final done = task.status == TaskStatus.done || task.isCompleted;
  if (done) {
    return _DueBadgeData(
      label: context.l10n.taskBadgeDone,
      background: cs.tertiaryContainer,
      foreground: cs.onTertiaryContainer,
    );
  }

  if (task.dueDateTime == null) {
    return _DueBadgeData(
      label: context.l10n.taskBadgeNoDate,
      background: cs.surfaceContainerHighest,
      foreground: cs.onSurfaceVariant,
    );
  }

  final today = DateUtils.dateOnly(DateTime.now());
  final due = DateUtils.dateOnly(task.dueDateTime!);

  if (due.isAtSameMomentAs(today)) {
    return _DueBadgeData(
      label: context.l10n.taskBadgeToday,
      background: cs.secondaryContainer,
      foreground: cs.onSecondaryContainer,
    );
  }

  if (due.isBefore(today)) {
    return _DueBadgeData(
      label: context.l10n.taskBadgeOverdue,
      background: cs.errorContainer,
      foreground: cs.onErrorContainer,
    );
  }

  return _DueBadgeData(
    label: context.l10n.taskBadgeUpcoming,
    background: cs.primaryContainer,
    foreground: cs.onPrimaryContainer,
  );
}