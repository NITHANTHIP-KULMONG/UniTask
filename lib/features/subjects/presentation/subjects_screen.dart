import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../domain/subject.dart';
import 'subject_controller.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(userSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Subject'),
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
                Text('Failed to load subjects.\n$e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(userSubjectsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (subjects) {
          if (subjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('No subjects yet',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first subject.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        subject.color.color.withValues(alpha: 0.15),
                    child: Icon(Icons.circle,
                        size: 16, color: subject.color.color),
                  ),
                  title: Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openEditDialog(context, ref, subject),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, subject),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_SubjectDialogResult>(
      context: context,
      builder: (_) => const _SubjectFormDialog(
        dialogTitle: 'Add Subject',
        confirmLabel: 'Add',
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
          SnackBar(content: Text('"${result.name}" created')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create subject: $e')),
        );
      }
    }
  }

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final result = await showDialog<_SubjectDialogResult>(
      context: context,
      builder: (_) => _SubjectFormDialog(
        dialogTitle: 'Edit Subject',
        confirmLabel: 'Save',
        initialName: subject.name,
        initialColor: subject.color,
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
          SnackBar(content: Text('"${result.name}" updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subject: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Delete "${subject.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref.read(subjectControllerProvider).deleteById(subject.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${subject.name}" deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete subject: $e')),
        );
      }
    }
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

class _SubjectFormDialog extends StatefulWidget {
  const _SubjectFormDialog({
    required this.dialogTitle,
    required this.confirmLabel,
    this.initialName = '',
    this.initialColor = SubjectColor.indigo,
  });

  final String dialogTitle;
  final String confirmLabel;
  final String initialName;
  final SubjectColor initialColor;

  @override
  State<_SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<_SubjectFormDialog> {
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
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Subject name'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Text('Colour',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
