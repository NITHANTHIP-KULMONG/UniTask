import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
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
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('New Task'),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Title',
                        hintText: 'What needs to be done?',
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Optional notes',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDueDate == null
                                    ? 'No due date'
                                    : MaterialLocalizations.of(context)
                                        .formatMediumDate(_selectedDueDate!),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: _pickDueDate,
                              child: const Text('Pick date'),
                            ),
                            if (_selectedDueDate != null)
                              IconButton(
                                tooltip: 'Clear due date',
                                onPressed: () {
                                  setState(() => _selectedDueDate = null);
                                },
                                icon: const Icon(Icons.clear_rounded),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (subjectsAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Create',
                        onPressed: canCreate ? _createTask : null,
                        isLoading: _isSubmitting,
                        icon: Icons.add_task_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
