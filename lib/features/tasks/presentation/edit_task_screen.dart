import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../subjects/presentation/subject_controller.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isReady = false;
  bool _isSaving = false;
  String? _selectedSubjectId;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = _findTask();
    final subjects = ref.watch(userSubjectsProvider).valueOrNull ?? const [];

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Assignment')),
        body: const Center(child: Text('Task not found.')),
      );
    }

    if (!_isReady) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedSubjectId = task.subjectId;
      _selectedDueDate = task.dueDate;
      _isReady = true;
    }
    final selectedSubjectValue = subjects.any((s) => s.id == _selectedSubjectId)
        ? _selectedSubjectId
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Assignment')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit assignment',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Update details and save changes.',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Title is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedSubjectValue,
                            decoration:
                                const InputDecoration(labelText: 'Subject'),
                            items: subjects
                                .map(
                                  (s) => DropdownMenuItem<String>(
                                    value: s.id,
                                    child: Text(s.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _selectedSubjectId = v;
                            }),
                            validator: (_) {
                              if (selectedSubjectValue == null) {
                                return 'Subject is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Due date',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDueDate,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              _selectedDueDate == null
                                  ? 'No due date'
                                  : 'Due ${DateFormat.yMMMd().format(_selectedDueDate!)}',
                            ),
                          ),
                          if (_selectedDueDate != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _selectedDueDate = null);
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear due date'),
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            minLines: 2,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : () => _save(task),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Task? _findTask() {
    final tasks = ref.watch(userTasksProvider).valueOrNull;
    if (tasks == null) return widget.task;

    for (final t in tasks) {
      if (t.id == widget.task.id) return t;
    }
    return null;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _selectedDueDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDueDate = DateUtils.dateOnly(picked);
    });
  }

  Future<void> _save(Task task) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(taskServiceProvider).updateTask(task.id, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'subjectId': _selectedSubjectId!,
        'dueDate': _selectedDueDate,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
      setState(() => _isSaving = false);
    }
  }
}
