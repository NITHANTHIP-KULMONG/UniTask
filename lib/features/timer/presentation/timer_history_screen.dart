import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../domain/timer_session.dart';
import 'timer_controller.dart';

class TimerHistoryScreen extends ConsumerWidget {
  const TimerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(timerSessionsProvider);
    final subjectsState = ref.watch(subjectControllerProvider);

    final subjects = subjectsState.valueOrNull ?? <Subject>[];
    final subjectNameById = <String, String>{
      for (final s in subjects) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(timerSessionsProvider.notifier).load(),
          ),
        ],
      ),
      body: sessionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(timerSessionsProvider.notifier).load(),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                'No timer history yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final grouped = _groupByDate(sessions);
          final dateKeys = grouped.keys.toList(growable: false);

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final date = dateKeys[index];
              final items = grouped[date] ?? const <TimerSession>[];

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Text(
                        date,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    ...items.map(
                      (session) {
                        final subjectName =
                            subjectNameById[session.subjectId] ?? 'Unknown subject';
                        final startTime = _fmtTime(session.startAt);
                        final duration = _fmtDuration(session.durationSeconds);

                        return Card(
                          child: ListTile(
                            title: Text(
                              subjectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('$duration - Start $startTime'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref
                                    .read(timerSessionsProvider.notifier)
                                    .deleteById(session.id);
                              },
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

  Map<String, List<TimerSession>> _groupByDate(List<TimerSession> sessions) {
    final map = <String, List<TimerSession>>{};
    for (final session in sessions) {
      final key = _fmtDate(session.startAt);
      map.putIfAbsent(key, () => <TimerSession>[]).add(session);
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
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final m = (safe ~/ 60).toString().padLeft(2, '0');
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

