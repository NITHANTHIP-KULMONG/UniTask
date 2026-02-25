import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/home_shell.dart';
import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../domain/timer_session.dart';
import 'timer_controller.dart';
import 'timer_history_screen.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsState = ref.watch(subjectControllerProvider);
    final sessionsState = ref.watch(timerSessionsProvider);
    final runState = ref.watch(timerRunProvider);
    final runController = ref.read(timerRunProvider.notifier);

    final subjects = subjectsState.valueOrNull ?? const <Subject>[];
    final hasSubjects = subjects.isNotEmpty;
    final selectedId = runState.selectedSubject?.id;
    final dropdownValue = subjects.any((s) => s.id == selectedId) ? selectedId : null;

    final canStart = hasSubjects && !runState.isRunning && dropdownValue != null;
    final canPause = hasSubjects && runState.isRunning && !runState.isPaused;
    final canResume = hasSubjects && runState.isRunning && runState.isPaused;
    final canStop = hasSubjects && runState.isRunning;

    final subjectNameById = <String, String>{
      for (final s in subjects) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TimerHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Focused study sessions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          if (!hasSubjects) ...[
            _AddSubjectCard(
              onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 3,
            ),
            const SizedBox(height: 12),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: dropdownValue,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: subjects
                          .map(
                            (subject) => DropdownMenuItem<String>(
                              value: subject.id,
                              child: Text(
                                subject.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (id) {
                        if (id == null) return;
                        runController.selectSubject(id);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatElapsed(runState.elapsedSeconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _statusText(runState),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (!runState.isRunning)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: canStart ? runController.start : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start'),
                      ),
                    ),
                  if (runState.isRunning && !runState.isPaused)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: canPause ? runController.pause : null,
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('Pause'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: canStop ? runController.stopAndSave : null,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  if (runState.isRunning && runState.isPaused)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: canResume ? runController.resume : null,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Resume'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: canStop ? runController.stopAndSave : null,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent sessions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          sessionsState.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => ref.read(timerSessionsProvider.notifier).load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (sessions) {
              if (sessions.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timer_off_outlined,
                          size: 42,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No sessions yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start a timer to create your first session.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final recent = sessions.take(4).toList(growable: false);
              return Card(
                child: Column(
                  children: [
                    for (var i = 0; i < recent.length; i++) ...[
                      _RecentSessionTile(
                        session: recent[i],
                        subjectName:
                            subjectNameById[recent[i].subjectId] ?? 'Unknown subject',
                      ),
                      if (i != recent.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddSubjectCard extends StatelessWidget {
  const _AddSubjectCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'Add a subject first',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Timer sessions must be linked to a subject.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onTap,
              child: const Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  const _RecentSessionTile({
    required this.session,
    required this.subjectName,
  });

  final TimerSession session;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: Text(subjectName),
      subtitle: Text(_formatDateTime(session.startAt)),
      trailing: Text(
        _formatElapsed(session.durationSeconds),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

String _statusText(TimerRunState state) {
  if (state.isRunning && state.isPaused) return 'Paused';
  if (state.isRunning) return 'Running';
  return 'Ready';
}

String _formatElapsed(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;

  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime dt) {
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

  final month = months[dt.month - 1];
  final day = dt.day.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$month $day, ${dt.year} • $hour:$minute';
}

