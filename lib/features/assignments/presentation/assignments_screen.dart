import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../domain/assignment.dart';
import '../domain/priority_utils.dart';
import 'add_assignment_sheet.dart';
import 'assignment_controller.dart';

enum TaskView { today, upcoming, done }

final taskViewProvider = StateProvider<TaskView>((ref) => TaskView.today);
final taskSubjectFilterProvider = StateProvider<String?>((ref) => null);
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(userAssignmentsProvider);
    final subjectsState = ref.watch(userSubjectsProvider);

    final subjects = subjectsState.valueOrNull ?? const <Subject>[];
    final subjectNameById = <String, String>{
      for (final subject in subjects) subject.id: subject.name,
    };

    final currentView = ref.watch(taskViewProvider);
    final selectedSubjectId = ref.watch(taskSubjectFilterProvider);
    final query = ref.watch(taskSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: assignmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(userAssignmentsProvider),
        ),
        data: (items) {
          final totalCount = items.length;
          final filtered = _filterAndSort(
            items: items,
            subjectNameById: subjectNameById,
            currentView: currentView,
            selectedSubjectId: selectedSubjectId,
            query: query,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _SearchField(
                  onChanged: (value) {
                    ref.read(taskSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: selectedSubjectId == null,
                      onSelected: (_) => ref.read(taskSubjectFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 8),
                    ...subjects.map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(subject.name),
                          selected: selectedSubjectId == subject.id,
                          onSelected: (_) {
                            ref.read(taskSubjectFilterProvider.notifier).state = subject.id;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<TaskView>(
                  segments: const [
                    ButtonSegment(value: TaskView.today, label: Text('Today')),
                    ButtonSegment(value: TaskView.upcoming, label: Text('Upcoming')),
                    ButtonSegment(value: TaskView.done, label: Text('Done')),
                  ],
                  selected: {currentView},
                  onSelectionChanged: (values) {
                    ref.read(taskViewProvider.notifier).state = values.first;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyView(onCreate: () => _openAddSheet(context))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final assignment = filtered[index];
                          return _AssignmentTile(
                            assignment: assignment,
                            subjectName:
                                subjectNameById[assignment.subjectId] ?? 'Unknown subject',
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Assignment> _filterAndSort({
    required List<Assignment> items,
    required Map<String, String> subjectNameById,
    required TaskView currentView,
    required String? selectedSubjectId,
    required String query,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final q = query.trim().toLowerCase();

    final filtered = items.where((assignment) {
      if (selectedSubjectId != null && assignment.subjectId != selectedSubjectId) {
        return false;
      }

      if (q.isNotEmpty) {
        final title = assignment.title.toLowerCase();
        final subject = (subjectNameById[assignment.subjectId] ?? '').toLowerCase();
        if (!title.contains(q) && !subject.contains(q)) {
          return false;
        }
      }

      final due = DateTime(
        assignment.dueDate.year,
        assignment.dueDate.month,
        assignment.dueDate.day,
      );

      return switch (currentView) {
        TaskView.today => !assignment.isDone && (due.isAtSameMomentAs(today) || due.isBefore(today)),
        TaskView.upcoming => !assignment.isDone && due.isAfter(today),
        TaskView.done => assignment.isDone,
      };
    }).toList(growable: false);

    final sorted = [...filtered]
      ..sort((a, b) {
        if (currentView == TaskView.done) {
          return b.dueDate.compareTo(a.dueDate);
        }

        final byPriority = priorityScore(b.weightPercent, b.dueDate).compareTo(
          priorityScore(a.weightPercent, a.dueDate),
        );
        if (byPriority != 0) return byPriority;
        return a.dueDate.compareTo(b.dueDate);
      });

    return sorted;
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddAssignmentSheet(),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search assignments',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        isDense: true,
      ),
    );
  }
}

class _AssignmentTile extends ConsumerWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.subjectName,
  });

  final Assignment assignment;
  final String subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strike = assignment.isDone ? TextDecoration.lineThrough : null;

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: assignment.isDone,
          onChanged: (_) => ref
              .read(assignmentControllerProvider)
              .toggleDone(assignment.id, assignment.isDone),
        ),
        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(decoration: strike),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$subjectName • Due ${_fmtDateLong(assignment.dueDate)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _PriorityBadge(score: priorityScore(assignment.weightPercent, assignment.dueDate)),
                _DueBadge(assignment: assignment),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            ref.read(assignmentControllerProvider).deleteById(assignment.id);
          },
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

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );

    String label;
    Color bg;
    Color fg;

    if (assignment.isDone) {
      label = 'Done';
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    } else if (due.isBefore(today)) {
      label = 'Overdue';
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
    } else if (due.isAtSameMomentAs(today)) {
      label = 'Today';
      bg = scheme.tertiaryContainer;
      fg = scheme.onTertiaryContainer;
    } else {
      final days = daysRemaining(assignment.dueDate);
      label = '${days}d';
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }

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
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  'No assignments found',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Try changing filters or create a new assignment.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onCreate,
                  child: const Text('Create assignment'),
                ),
              ],
            ),
          ),
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
  final month = months[d.month - 1];
  return '$month ${d.day}, ${d.year}';
}

