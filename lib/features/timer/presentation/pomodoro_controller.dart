import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../subjects/domain/subject.dart';
import '../domain/pomodoro_preferences.dart';
import '../domain/study_session.dart';
import '../services/study_session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final pomodoroProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>(
  (ref) => PomodoroController(ref),
);

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Which phase the Pomodoro is currently in.
enum PomodoroPhase { idle, work, shortBreak, longBreak }

class PomodoroState {
  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isPaused = false,
    this.completedPomodoros = 0,
    this.selectedSubject,
  });

  /// Current phase of the Pomodoro cycle.
  final PomodoroPhase phase;

  /// Seconds left in the current interval (counts down).
  final int remainingSeconds;

  /// Total seconds for this interval (used for progress ring).
  final int totalSeconds;

  /// Whether the timer is paused mid-interval.
  final bool isPaused;

  /// How many work sessions have been completed in this cycle.
  final int completedPomodoros;

  /// The subject linked to the current session.
  final Subject? selectedSubject;

  bool get isRunning => phase != PomodoroPhase.idle && !isPaused;
  bool get isActive => phase != PomodoroPhase.idle;
  bool get isWorkPhase => phase == PomodoroPhase.work;

  double get progress =>
      totalSeconds > 0 ? 1.0 - (remainingSeconds / totalSeconds) : 0.0;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isPaused,
    int? completedPomodoros,
    Subject? selectedSubject,
    bool clearSubject = false,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isPaused: isPaused ?? this.isPaused,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      selectedSubject:
          clearSubject ? null : (selectedSubject ?? this.selectedSubject),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController(this._ref) : super(const PomodoroState());

  final Ref _ref;
  Timer? _ticker;
  DateTime? _phaseStartedAt;

  // ── Subject selection ──────────────────────────────────────────────

  void selectSubject(Subject subject) {
    if (state.isActive) return; // can't change subject mid-session
    state = state.copyWith(selectedSubject: subject);
  }

  // ── Timer controls ─────────────────────────────────────────────────

  /// Start a new work interval (or the first one).
  void start() {
    if (state.selectedSubject == null) return;
    if (state.isActive) return;

    final prefs = _ref.read(pomodoroPrefsProvider);
    final secs = prefs.workSeconds;

    _phaseStartedAt = DateTime.now();
    state = state.copyWith(
      phase: PomodoroPhase.work,
      remainingSeconds: secs,
      totalSeconds: secs,
      isPaused: false,
    );
    _startTicker();
  }

  void pause() {
    if (!state.isActive || state.isPaused) return;
    _cancelTicker();
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    if (!state.isActive || !state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _startTicker();
  }

  /// Reset the timer back to idle without saving.
  void reset() {
    _cancelTicker();
    _phaseStartedAt = null;
    state = PomodoroState(
      selectedSubject: state.selectedSubject,
    );
  }

  /// Skip the current interval (useful during breaks).
  void skip() {
    if (!state.isActive) return;
    _cancelTicker();
    _onIntervalComplete();
  }

  // ── Internal tick logic ────────────────────────────────────────────

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused) return;

      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _cancelTicker();
        _onIntervalComplete();
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Called when the countdown reaches zero.
  Future<void> _onIntervalComplete() async {
    if (state.phase == PomodoroPhase.work) {
      // Save the completed work session to Firestore.
      await _saveSession();

      final completed = state.completedPomodoros + 1;
      final prefs = _ref.read(pomodoroPrefsProvider);
      final isLongBreak =
          completed % prefs.sessionsBeforeLongBreak == 0;

      final breakPhase =
          isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      final breakSecs =
          isLongBreak ? prefs.longBreakSeconds : prefs.shortBreakSeconds;

      _phaseStartedAt = DateTime.now();
      state = state.copyWith(
        phase: breakPhase,
        remainingSeconds: breakSecs,
        totalSeconds: breakSecs,
        isPaused: false,
        completedPomodoros: completed,
      );
      _startTicker();
    } else {
      // Break finished → start next work interval automatically.
      final prefs = _ref.read(pomodoroPrefsProvider);
      final secs = prefs.workSeconds;

      _phaseStartedAt = DateTime.now();
      state = state.copyWith(
        phase: PomodoroPhase.work,
        remainingSeconds: secs,
        totalSeconds: secs,
        isPaused: false,
      );
      _startTicker();
    }
  }

  /// Persist the completed work session to Firestore.
  Future<void> _saveSession() async {
    final subject = state.selectedSubject;
    final startedAt = _phaseStartedAt;
    if (subject == null || startedAt == null) return;

    final uid = _ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final prefs = _ref.read(pomodoroPrefsProvider);
    final elapsed = prefs.workSeconds; // full interval duration

    final session = StudySession(
      id: _newId(),
      ownerId: uid,
      subjectId: subject.id,
      startAt: startedAt,
      endAt: now,
      durationSeconds: elapsed,
      sessionType: SessionType.work,
      pomodoroNumber: state.completedPomodoros + 1,
      createdAt: now,
    );

    try {
      await _ref.read(studySessionServiceProvider).saveSession(session);
    } catch (_) {
      // Swallow — don't crash the timer for a save failure.
    }
  }

  String _newId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final suffix = (ts % 100000).toString().padLeft(5, '0');
    return 'ss_$ts$suffix';
  }

  @override
  void dispose() {
    _cancelTicker();
    super.dispose();
  }
}
