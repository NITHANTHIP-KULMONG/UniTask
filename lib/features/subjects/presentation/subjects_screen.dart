import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../auth/services/auth_service.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../domain/subject.dart';
import 'subject_controller.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
    final subjectsAsync = ref.watch(userSubjectsProvider);
    final tasks = ref.watch(userTasksProvider).valueOrNull ?? const [];
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSubjects),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'subjectsFab',
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.subjectsNewSubject),
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(l10n.subjectsLoadFailed('$e'),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(userSubjectsProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (subjects) {
          final q = _query.toLowerCase();
          final filtered = q.isEmpty
              ? subjects
              : subjects
                  .where((s) => s.name.toLowerCase().contains(q))
                  .toList();

          final activeTaskCountBySubject = <String, int>{};
          for (final task in tasks) {
            if (task.status == TaskStatus.done || task.isCompleted) continue;
            activeTaskCountBySubject.update(
              task.subjectId,
              (v) => v + 1,
              ifAbsent: () => 1,
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.subjectsSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Expanded(
                child: subjects.isEmpty
                    ? _SubjectsEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: l10n.subjectsEmptyTitle,
                        message: l10n.subjectsEmptyMessage,
                      )
                    : filtered.isEmpty
                        ? _SubjectsEmptyState(
                            icon: Icons.search_off,
                            title: l10n.subjectsNoMatchTitle,
                            message: l10n.subjectsNoMatchMessage,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final subject = filtered[index];
                              final count =
                                  activeTaskCountBySubject[subject.id] ?? 0;
                              final countText =
                                  l10n.subjectsAssignmentCount(count);

                              return Hero(
                                tag: 'subject-${subject.id}',
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    leading: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: subject.color.color,
                                      ),
                                    ),
                                    title: Text(
                                      subject.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    subtitle: Text(
                                      countText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    onTap: () =>
                                        _openEditDialog(context, ref, subject),
                                    trailing: PopupMenuButton<_SubjectAction>(
                                      tooltip: l10n.commonMore,
                                      onSelected: (action) {
                                        if (action == _SubjectAction.edit) {
                                          _openEditDialog(
                                              context, ref, subject);
                                          return;
                                        }
                                        _confirmDelete(context, ref, subject);
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: _SubjectAction.edit,
                                          child: Text(l10n.taskActionEdit),
                                        ),
                                        PopupMenuItem(
                                          value: _SubjectAction.delete,
                                          child: Text(l10n.commonDelete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<_SubjectDialogResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SubjectFormSheet(
        sheetTitle: l10n.subjectsAddTitle,
        confirmLabel: l10n.commonAdd,
      ),
    );

    if (!context.mounted || result == null) return;

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    try {
      await ref.read(subjectControllerProvider).add(
            name: result.name,
            ownerId: uid,
            color: result.color,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsCreated(result.name))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsCreateFailed('$e'))),
        );
      }
    }
  }

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<_SubjectDialogResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SubjectFormSheet(
        sheetTitle: l10n.subjectsEditTitle,
        confirmLabel: l10n.commonSave,
        initialName: subject.name,
        initialColor: subject.color,
        subjectId: subject.id,
      ),
    );

    if (!context.mounted || result == null) return;
    if (result.name == subject.name && result.color == subject.color) return;

    try {
      await ref.read(subjectControllerProvider).update(
            subject.copyWith(name: result.name, color: result.color),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsUpdated(result.name))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsUpdateFailed('$e'))),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.subjectsDeleteTitle),
        content: Text(l10n.subjectsDeleteMessage(subject.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref.read(subjectControllerProvider).deleteById(subject.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsDeleted(subject.name))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subjectsDeleteFailed('$e'))),
        );
      }
    }
  }
}

enum _SubjectAction { edit, delete }

class _SubjectsEmptyState extends StatelessWidget {
  const _SubjectsEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
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
// Dialog result
// =============================================================================

class _SubjectDialogResult {
  const _SubjectDialogResult(this.name, this.color);
  final String name;
  final SubjectColor color;
}

// =============================================================================
// Subject form dialog (name + colour picker)
// =============================================================================

class _SubjectFormSheet extends StatefulWidget {
  const _SubjectFormSheet({
    required this.sheetTitle,
    required this.confirmLabel,
    this.initialName = '',
    this.initialColor = SubjectColor.indigo,
    this.subjectId,
  });

  final String sheetTitle;
  final String confirmLabel;
  final String initialName;
  final SubjectColor initialColor;
  final String? subjectId;

  @override
  State<_SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<_SubjectFormSheet> {
  late final TextEditingController _nameCtrl;
  late SubjectColor _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, _SubjectDialogResult(name, _selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.sheetTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: l10n.subjectsNameLabel),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Text(l10n.subjectsColorLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubjectColor.values.map((sc) {
              final isSelected = sc == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = sc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: sc.color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
