import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../../tasks/presentation/user_home_page.dart';
import '../domain/pomodoro_preferences.dart';
import '../services/study_session_service.dart';
import 'pomodoro_controller.dart';
import 'timer_history_screen.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(userSubjectsProvider);
    final pomo = ref.watch(pomodoroProvider);
    final pomoCtrl = ref.read(pomodoroProvider.notifier);
    final prefs = ref.watch(pomodoroPrefsProvider);
    final dailySeconds = ref.watch(dailyStudySecondsProvider);
    final dailyPomodoros = ref.watch(dailyPomodoroCountProvider);

    final subjects = subjectsAsync.valueOrNull ?? const <Subject>[];
    final hasSubjects = subjects.isNotEmpty;
    final selectedId = pomo.selectedSubject?.id;
    final dropdownValue =
        subjects.any((s) => s.id == selectedId) ? selectedId : null;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Settings',
            onPressed: () => _showPrefsDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TimerHistoryScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Daily summary card ───────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '$dailyPomodoros pomodoros • ${_fmtDuration(dailySeconds)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Subject selector ─────────────────────────────────
          if (!hasSubjects) ...[
            _AddSubjectCard(
              onTap: () =>
                  ref.read(selectedTabIndexProvider.notifier).state = 2,
            ),
            const SizedBox(height: 12),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: subjects
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: pomo.isActive
                          ? null
                          : (id) {
                              if (id == null) return;
                              final subj =
                                  subjects.firstWhere((s) => s.id == id);
                              pomoCtrl.selectSubject(subj);
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Circular countdown ───────────────────────────────
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: pomo.progress,
                  ringColor: _phaseColor(pomo.phase, cs),
                  trackColor: cs.surfaceContainerHighest,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmtCountdown(pomo.remainingSeconds),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phaseLabel(pomo),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Pomodoro dots ────────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                prefs.sessionsBeforeLongBreak,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < pomo.completedPomodoros
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 14,
                    color: i < pomo.completedPomodoros
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Control buttons ──────────────────────────────────
          _buildControls(context, pomo, pomoCtrl, hasSubjects, dropdownValue),
        ],
      ),
    );
  }

  // ── Controls builder ──────────────────────────────────────────────

  Widget _buildControls(
    BuildContext context,
    PomodoroState pomo,
    PomodoroController ctrl,
    bool hasSubjects,
    String? dropdownValue,
  ) {
    if (!pomo.isActive) {
      // Idle → Start
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed:
              hasSubjects && dropdownValue != null ? ctrl.start : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Focus'),
        ),
      );
    }

    return Row(
      children: [
        // Pause / Resume
        Expanded(
          child: pomo.isPaused
              ? FilledButton.icon(
                  onPressed: ctrl.resume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                )
              : FilledButton.tonalIcon(
                  onPressed: ctrl.pause,
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('Pause'),
                ),
        ),
        const SizedBox(width: 10),

        // Skip (during breaks)
        if (!pomo.isWorkPhase)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: ctrl.skip,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Skip'),
            ),
          ),
        if (!pomo.isWorkPhase) const SizedBox(width: 10),

        // Reset
        Expanded(
          child: FilledButton.icon(
            onPressed: ctrl.reset,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Reset'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }

  // ── Preferences dialog ────────────────────────────────────────────

  void _showPrefsDialog(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(pomodoroPrefsProvider);
    final workCtrl =
        TextEditingController(text: prefs.workMinutes.toString());
    final shortCtrl =
        TextEditingController(text: prefs.shortBreakMinutes.toString());
    final longCtrl =
        TextEditingController(text: prefs.longBreakMinutes.toString());
    final roundsCtrl = TextEditingController(
        text: prefs.sessionsBeforeLongBreak.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Timer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workCtrl,
              decoration: const InputDecoration(
                  labelText: 'Work (min)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: shortCtrl,
              decoration: const InputDecoration(
                  labelText: 'Short break (min)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: longCtrl,
              decoration: const InputDecoration(
                  labelText: 'Long break (min)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roundsCtrl,
              decoration: const InputDecoration(
                  labelText: 'Rounds before long break',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final w = int.tryParse(workCtrl.text) ?? 25;
              final s = int.tryParse(shortCtrl.text) ?? 5;
              final l = int.tryParse(longCtrl.text) ?? 15;
              final r = int.tryParse(roundsCtrl.text) ?? 4;

              ref.read(pomodoroPrefsProvider.notifier).state =
                  PomodoroPreferences(
                workMinutes: w.clamp(1, 120),
                shortBreakMinutes: s.clamp(1, 60),
                longBreakMinutes: l.clamp(1, 60),
                sessionsBeforeLongBreak: r.clamp(1, 12),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Internal widgets
// =============================================================================

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
            Icon(Icons.school_outlined,
                size: 42,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text('Add a subject first',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Timer sessions must be linked to a subject.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onTap, child: const Text('Add Subject')),
          ],
        ),
      ),
    );
  }
}

/// Paints a circular progress ring.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  final double progress;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = ringColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.ringColor != ringColor ||
      old.trackColor != trackColor;
}

// =============================================================================
// Helpers
// =============================================================================

Color _phaseColor(PomodoroPhase phase, ColorScheme cs) {
  return switch (phase) {
    PomodoroPhase.idle => cs.outline,
    PomodoroPhase.work => cs.primary,
    PomodoroPhase.shortBreak => cs.tertiary,
    PomodoroPhase.longBreak => cs.secondary,
  };
}

String _phaseLabel(PomodoroState state) {
  if (!state.isActive) return 'Ready';
  if (state.isPaused) return 'Paused';
  return state.phase == PomodoroPhase.work
      ? 'Focus Time'
      : state.phase == PomodoroPhase.shortBreak
          ? 'Short Break'
          : 'Long Break';
}

String _fmtCountdown(int seconds) {
  final s = seconds.clamp(0, 99999);
  final m = s ~/ 60;
  final sec = s % 60;
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

String _fmtDuration(int totalSeconds) {
  final safe = totalSeconds.clamp(0, 999999);
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  if (h > 0) {
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
  return '${m}m ${s.toString().padLeft(2, '0')}s';
}

