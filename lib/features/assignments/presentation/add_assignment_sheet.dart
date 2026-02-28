import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../tasks/presentation/user_home_page.dart';
import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../domain/assignment.dart';
import 'assignment_controller.dart';

class AddAssignmentSheet extends ConsumerStatefulWidget {
  const AddAssignmentSheet({super.key});

  @override
  ConsumerState<AddAssignmentSheet> createState() => _AddAssignmentSheetState();
}

class _AddAssignmentSheetState extends ConsumerState<AddAssignmentSheet> {
  final _titleCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '10');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  Subject? _selectedSubject;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: today,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;
    setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text.trim());

    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (weight == null || weight <= 0 || weight > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be 1-100')),
      );
      return;
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final assignment = Assignment(
        id: '',  // Firestore auto-generates the ID
        ownerId: uid,
        subjectId: _selectedSubject!.id,
        title: title,
        dueDate: _dueDate,
        weightPercent: weight,
        isDone: false,
        createdAt: now,
      );

      await ref.read(assignmentControllerProvider).add(assignment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create assignment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(userSubjectsProvider);
    final subjects = subjectsState.valueOrNull ?? <Subject>[];
    if (_selectedSubject == null && subjects.isNotEmpty) {
      _selectedSubject = subjects.first;
    }

    final hasSubjects = subjects.isNotEmpty;
    final canSave = !_saving && hasSubjects && _selectedSubject != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final dueText =
        '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Assignment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (!hasSubjects) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please create a subject first.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(selectedTabIndexProvider.notifier).state = 2;
                  },
                  child: const Text('Create subject'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Subject>(
            value: _selectedSubject,
            items: subjects
                .map(
                  (subject) => DropdownMenuItem<Subject>(
                    value: subject,
                    child: Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (!hasSubjects || _saving)
                ? null
                : (subject) {
                    setState(() => _selectedSubject = subject);
                  },
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight %',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(dueText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSave ? _submit : null,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
