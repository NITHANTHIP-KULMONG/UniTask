import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/presentation/subject_controller.dart';
import '../services/task_service.dart';

class NewTaskDialog extends ConsumerStatefulWidget {
  const NewTaskDialog({super.key});

  @override
  ConsumerState<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends ConsumerState<NewTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedSubjectId;
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final firstDate = DateTime.now();

    final initialDate = _selectedDueDate != null &&
            !DateUtils.dateOnly(_selectedDueDate!).isBefore(today)
        ? _selectedDueDate!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;
    if (DateUtils.dateOnly(picked).isBefore(today)) return;

    setState(() {
      _selectedDueDate = DateUtils.dateOnly(picked);
    });
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(taskServiceProvider).createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            subjectId: _selectedSubjectId!,
            dueDate: _selectedDueDate,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create task: $error')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(userSubjectsProvider);

    final subjects = subjectsAsync.valueOrNull ?? const [];
    final canCreate = !_isSubmitting && _selectedSubjectId != null;

    return AlertDialog(
      title: const Text('New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.newline,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubjectId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: subjects
                    .map(
                      (subject) => DropdownMenuItem<String>(
                        value: subject.id,
                        child: Text(subject.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSubjectId = value);
                },
                validator: (_) {
                  if (_selectedSubjectId == null) {
                    return 'Subject is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDueDate == null
                          ? 'No due date'
                          : MaterialLocalizations.of(context)
                              .formatMediumDate(_selectedDueDate!),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDueDate,
                    child: const Text('Pick Due Date'),
                  ),
                  if (_selectedDueDate != null)
                    IconButton(
                      tooltip: 'Clear due date',
                      onPressed: () {
                        setState(() => _selectedDueDate = null);
                      },
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
              if (subjectsAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canCreate ? _createTask : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
