import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-configurable Pomodoro durations (in minutes).
///
/// Stored in-memory for now; ready to persist to Firestore user preferences
/// when the settings screen is built.
class PomodoroPreferences {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  const PomodoroPreferences({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  int get workSeconds => workMinutes * 60;
  int get shortBreakSeconds => shortBreakMinutes * 60;
  int get longBreakSeconds => longBreakMinutes * 60;

  PomodoroPreferences copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
  }) {
    return PomodoroPreferences(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
    );
  }
}

/// Global user preferences provider — widgets can read/write this.
final pomodoroPrefsProvider =
    StateProvider<PomodoroPreferences>((ref) => const PomodoroPreferences());
