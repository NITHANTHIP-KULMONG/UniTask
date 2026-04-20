import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../subjects/domain/subject.dart';
import '../../subjects/presentation/subject_controller.dart';
import '../../subjects/presentation/subjects_screen.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTimer),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.timerTooltipSettings,
            onPressed: () => _showPrefsDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.timerTooltipHistory,
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
                          l10n.timerToday,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          l10n.timerDailySummary(
                            dailyPomodoros,
                            _fmtDuration(context, dailySeconds),
                          ),
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
              title: l10n.subjectRequiredTitle,
              description: l10n.timerSubjectRequiredDescription,
              buttonLabel: l10n.subjectRequiredAction,
              onTap: () => _openSubjects(context, ref),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.timerSubjectLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: dropdownValue,
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
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: pomo.progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      ringColor: _phaseColor(pomo.phase, cs),
                      trackColor: cs.surfaceContainerHighest,
                    ),
                    child: child,
                  );
                },
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
                        _phaseLabel(context, pomo),
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

  void _openSubjects(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentTab = ref.read(selectedTabIndexProvider);

    if (currentTab == 3) {
      ref.read(selectedTabIndexProvider.notifier).state = 3;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.timerGoToSubjectsSnack)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubjectsScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.timerGoToSubjectsSnack)),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: child,
        ),
      ),
      child: !pomo.isActive
          ? SizedBox(
              key: const ValueKey('start_btn'),
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    hasSubjects && dropdownValue != null ? ctrl.start : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.l10n.timerStartFocus),
              ),
            )
          : Row(
              key: const ValueKey('active_controls'),
              children: [
                // Pause / Resume
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: pomo.isPaused
                        ? FilledButton.icon(
                            key: const ValueKey('resume'),
                            onPressed: ctrl.resume,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(context.l10n.timerResume),
                          )
                        : FilledButton.tonalIcon(
                            key: const ValueKey('pause'),
                            onPressed: ctrl.pause,
                            icon: const Icon(Icons.pause_rounded),
                            label: Text(context.l10n.timerPause),
                          ),
                  ),
                ),
                const SizedBox(width: 10),

                // Skip (during breaks)
                if (!pomo.isWorkPhase) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ctrl.skip,
                      icon: const Icon(Icons.skip_next_rounded),
                      label: Text(context.l10n.timerSkip),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Reset
                Expanded(
                  child: FilledButton.icon(
                    onPressed: ctrl.reset,
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(context.l10n.timerReset),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Preferences dialog ────────────────────────────────────────────

  void _showPrefsDialog(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(pomodoroPrefsProvider);
    final l10n = context.l10n;
    final workCtrl = TextEditingController(text: prefs.workMinutes.toString());
    final shortCtrl =
        TextEditingController(text: prefs.shortBreakMinutes.toString());
    final longCtrl =
        TextEditingController(text: prefs.longBreakMinutes.toString());
    final roundsCtrl =
        TextEditingController(text: prefs.sessionsBeforeLongBreak.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.timerSettingsTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrefsNumberField(
                label: l10n.timerSettingsWorkMinutesLabel,
                hint: '1-120',
                controller: workCtrl,
              ),
              const SizedBox(height: 12),
              _PrefsNumberField(
                label: l10n.timerSettingsShortBreakMinutesLabel,
                hint: '1-60',
                controller: shortCtrl,
              ),
              const SizedBox(height: 12),
              _PrefsNumberField(
                label: l10n.timerSettingsLongBreakMinutesLabel,
                hint: '1-60',
                controller: longCtrl,
              ),
              const SizedBox(height: 12),
              _PrefsNumberField(
                label: l10n.timerSettingsRoundsLabel,
                hint: '1-12',
                controller: roundsCtrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
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
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Internal widgets
// =============================================================================

class _PrefsNumberField extends StatelessWidget {
  const _PrefsNumberField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _AddSubjectCard extends StatelessWidget {
  const _AddSubjectCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 42, color: cs.onSurface),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onTap, child: Text(buttonLabel)),
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
    const strokeWidth = 10.0;
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

String _phaseLabel(BuildContext context, PomodoroState state) {
  final l10n = context.l10n;
  if (!state.isActive) return l10n.timerPhaseReady;
  if (state.isPaused) return l10n.timerPhasePaused;
  return state.phase == PomodoroPhase.work
      ? l10n.timerPhaseFocus
      : state.phase == PomodoroPhase.shortBreak
          ? l10n.timerPhaseShortBreak
          : l10n.timerPhaseLongBreak;
}

String _fmtCountdown(int seconds) {
  final s = seconds.clamp(0, 99999);
  final m = s ~/ 60;
  final sec = s % 60;
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

String _fmtDuration(BuildContext context, int totalSeconds) {
  final l10n = context.l10n;
  final safe = totalSeconds.clamp(0, 999999);
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  if (h > 0) {
    return l10n.timerDurationHoursMinutes(h, m);
  }
  return l10n.timerDurationMinutesSeconds(m, s);
}
