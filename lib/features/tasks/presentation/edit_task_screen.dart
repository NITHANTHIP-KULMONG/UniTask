import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
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
  DateTime? _selectedDueDateTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final task = _findTask();
    final subjects = ref.watch(userSubjectsProvider).valueOrNull ?? const [];

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.taskEditTitle)),
        body: Center(child: Text(l10n.taskEditNotFound)),
      );
    }

    if (!_isReady) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedSubjectId = task.subjectId;
      _selectedDueDateTime = task.dueDateTime;
      _isReady = true;
    }
    final selectedSubjectValue = subjects.any((s) => s.id == _selectedSubjectId)
        ? _selectedSubjectId
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskEditTitle)),
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
                            l10n.taskEditHeader,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.taskEditSubtitle,
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
                            decoration: InputDecoration(
                                labelText: l10n.taskFormTitleLabel),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.taskFormTitleRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          FormField<String>(
                            initialValue: selectedSubjectValue,
                            validator: (_) {
                              if (selectedSubjectValue == null) {
                                return l10n.taskFormSubjectRequired;
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.taskFormSelectSubject,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: state.hasError
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : null,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 56,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subjects.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final subject = subjects[index];
                                        final isSelected =
                                            selectedSubjectValue == subject.id;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() => _selectedSubjectId =
                                                subject.id);
                                            state.didChange(subject.id);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? subject.color.color
                                                      .withOpacity(0.15)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                              border: Border.all(
                                                color: isSelected
                                                    ? subject.color.color
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: subject.color.color,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  subject.name,
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? subject.color.color
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 16),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.taskDueDateLabel,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDueDateTime,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              _selectedDueDateTime == null
                                  ? l10n.taskNoDueDate
                                  : l10n.taskSubtitleDue(DateFormat(
                                      'MMM d, HH:mm',
                                      Localizations.localeOf(context)
                                          .toLanguageTag(),
                                    ).format(_selectedDueDateTime!)),
                            ),
                          ),
                          if (_selectedDueDateTime != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _selectedDueDateTime = null);
                              },
                              icon: const Icon(Icons.clear),
                              label: Text(l10n.taskClearDueDate),
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: l10n.taskFormDescriptionLabel,
                            ),
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
                  label:
                      Text(_isSaving ? l10n.taskSaving : l10n.taskSaveChanges),
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

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final initial = _selectedDueDateTime != null &&
            !DateUtils.dateOnly(_selectedDueDateTime!).isBefore(today)
        ? _selectedDueDateTime!
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDueDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDueDateTime!)
          : const TimeOfDay(hour: 18, minute: 0),
    );

    final safeTime = pickedTime ?? const TimeOfDay(hour: 18, minute: 0);
    final selectedDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      safeTime.hour,
      safeTime.minute,
    );

    if (!selectedDateTime.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskFormFutureDateRequired)),
      );
      return;
    }

    setState(() {
      _selectedDueDateTime = selectedDateTime;
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
        'dueDateTime': _selectedDueDateTime,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskSaveFailed('$e'))),
      );
      setState(() => _isSaving = false);
    }
  }
}
