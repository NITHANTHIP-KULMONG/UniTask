import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/subject.dart';
import 'subject_controller.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subjectControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(subjectControllerProvider.notifier).load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(subjectControllerProvider.notifier).load(),
        ),
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(
              child: Text('No subjects yet.'),
            );
          }

          final sorted = [...subjects]
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final subject = sorted[index];
              return Card(
                child: ListTile(
                  title: Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openRenameDialog(context, ref, subject),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(subjectControllerProvider.notifier).deleteById(subject.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (_) => const _SubjectNameDialog(
        title: 'Add subject',
        confirmLabel: 'Add',
      ),
    );

    if (!context.mounted) return;

    final name = (result ?? '').trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final subject = Subject(
      id: _newId(),
      name: name,
      createdAt: now,
    );

    await ref.read(subjectControllerProvider.notifier).add(subject);
  }

  Future<void> _openRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _SubjectNameDialog(
        title: 'Rename subject',
        initialText: subject.name,
        confirmLabel: 'Save',
      ),
    );

    if (!context.mounted) return;

    final newName = (result ?? '').trim();
    if (newName.isEmpty || newName == subject.name) return;

    await ref.read(subjectControllerProvider.notifier).update(
          subject.copyWith(name: newName),
        );
  }

  String _newId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final suffix = (ts % 100000).toString().padLeft(5, '0');
    return 's_$ts$suffix';
  }
}

class _SubjectNameDialog extends StatefulWidget {
  const _SubjectNameDialog({
    required this.title,
    required this.confirmLabel,
    this.initialText = '',
  });

  final String title;
  final String initialText;
  final String confirmLabel;

  @override
  State<_SubjectNameDialog> createState() => _SubjectNameDialogState();
}

class _SubjectNameDialogState extends State<_SubjectNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close(String? value) {
    FocusScope.of(context).unfocus();
    Navigator.of(context, rootNavigator: true).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Subject name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _close(_controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => _close(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _close(_controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
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
