import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
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
  DateTime? _selectedDueDateTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final firstDate = today;

    final initialDate = _selectedDueDateTime != null &&
            !DateUtils.dateOnly(_selectedDueDateTime!).isBefore(today)
        ? _selectedDueDateTime!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;
    if (DateUtils.dateOnly(picked).isBefore(today)) return;

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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(taskServiceProvider).createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            subjectId: _selectedSubjectId!,
            dueDateTime: _selectedDueDateTime,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskFormCreateFailed('$error'))),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(userSubjectsProvider);
    final l10n = context.l10n;

    final subjects = subjectsAsync.valueOrNull ?? const [];
    final canCreate = !_isSubmitting && _selectedSubjectId != null;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      l10n.taskFormCreateTaskTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _titleController,
                      label: l10n.taskFormTitleLabel,
                      hintText: l10n.taskFormTitleHint,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.taskFormTitleRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: l10n.taskFormDescriptionLabel,
                      hintText: l10n.taskFormDescriptionHint,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    FormField<String>(
                      initialValue: _selectedSubjectId,
                      validator: (_) {
                        if (_selectedSubjectId == null) {
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
                                        ? Theme.of(context).colorScheme.error
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
                                      _selectedSubjectId == subject.id;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                          _selectedSubjectId = subject.id);
                                      state.didChange(subject.id);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? subject.color.color
                                                .withOpacity(0.15)
                                            : cs.surfaceContainerHighest,
                                        border: Border.all(
                                          color: isSelected
                                              ? subject.color.color
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
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
                                                  : cs.onSurfaceVariant,
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
                                padding:
                                    const EdgeInsets.only(top: 8, left: 16),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickDueDateTime,
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedDueDateTime != null
                                ? cs.primaryContainer.withOpacity(0.5)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedDueDateTime != null
                                  ? cs.primary.withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: _selectedDueDateTime != null
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDueDateTime == null
                                      ? l10n.taskFormNoDueDateTap
                                      : DateFormat(
                                          'MMM d, yyyy • HH:mm',
                                          Localizations.localeOf(context)
                                              .toLanguageTag(),
                                        ).format(_selectedDueDateTime!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _selectedDueDateTime != null
                                            ? cs.onPrimaryContainer
                                            : cs.onSurfaceVariant,
                                        fontWeight: _selectedDueDateTime != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                              if (_selectedDueDateTime != null)
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedDueDateTime = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close,
                                        size: 16, color: cs.primary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (subjectsAsync.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: canCreate ? _createTask : null,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.add_rounded),
                            label: Text(
                              _isSubmitting
                                  ? l10n.taskFormCreating
                                  : l10n.dashboardCreateTask,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
