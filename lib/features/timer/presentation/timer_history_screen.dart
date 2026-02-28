import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../domain/study_session.dart';
import '../services/study_session_service.dart';

class TimerHistoryScreen extends ConsumerWidget {
  const TimerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userStudySessionsProvider);
    final subjectsAsync = ref.watch(userSubjectsProvider);

    final subjects = subjectsAsync.valueOrNull ?? <Subject>[];
    final subjectNameById = <String, String>{
      for (final s in subjects) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userStudySessionsProvider),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(userStudySessionsProvider),
        ),
        data: (sessions) {
          // Only show work sessions in the history.
          final workSessions = sessions
              .where((s) => s.sessionType == SessionType.work)
              .toList();

          if (workSessions.isEmpty) {
            return const Center(
              child: Text(
                'No study sessions yet.\nComplete a Pomodoro to see history.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final grouped = _groupByDate(workSessions);
          final dateKeys = grouped.keys.toList(growable: false);

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final date = dateKeys[index];
              final items = grouped[date] ?? const <StudySession>[];

              // Total duration for this date group.
              final totalSecs =
                  items.fold<int>(0, (s, i) => s + i.durationSeconds);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              date,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${items.length} sessions • ${_fmtDuration(totalSecs)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    ...items.map(
                      (session) {
                        final subjectName = subjectNameById[session.subjectId] ??
                            'Unknown subject';
                        final startTime = _fmtTime(session.startAt);
                        final duration =
                            _fmtDurationShort(session.durationSeconds);

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.local_fire_department,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              subjectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('$duration • $startTime'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(studySessionServiceProvider)
                                  .deleteSession(session.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<StudySession>> _groupByDate(List<StudySession> sessions) {
    final map = <String, List<StudySession>>{};
    for (final session in sessions) {
      final key = _fmtDate(session.startAt);
      map.putIfAbsent(key, () => <StudySession>[]).add(session);
    }
    return map;
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

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String _fmtTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _fmtDuration(int totalSeconds) {
  final safe = totalSeconds.clamp(0, 999999);
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

String _fmtDurationShort(int totalSeconds) {
  final safe = totalSeconds.clamp(0, 999999);
  final m = (safe ~/ 60).toString().padLeft(2, '0');
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

