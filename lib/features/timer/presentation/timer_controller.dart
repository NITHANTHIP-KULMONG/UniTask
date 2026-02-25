import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/domain/subject.dart';
import '../data/local_timer_repository.dart';
import '../domain/timer_repository.dart';
import '../domain/timer_session.dart';

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return const LocalTimerRepository();
});

final timerSessionsProvider =
    StateNotifierProvider<TimerSessionsController, AsyncValue<List<TimerSession>>>(
  (ref) => TimerSessionsController(ref.watch(timerRepositoryProvider)),
);

final timerRunProvider = StateNotifierProvider<TimerRunController, TimerRunState>(
  (ref) => TimerRunController(ref),
);

class TimerSessionsController extends StateNotifier<AsyncValue<List<TimerSession>>> {
  TimerSessionsController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final TimerRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<void> addSession(TimerSession s) async => _mutate(() => _repository.add(s));

  Future<void> deleteById(String id) async => _mutate(() => _repository.delete(id));

  Future<void> clear() async => _mutate(_repository.clear);

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      return _repository.getAll();
    });
  }
}

class TimerRunState {
  const TimerRunState({
    this.selectedSubject,
    this.isRunning = false,
    this.isPaused = false,
    this.elapsedSeconds = 0,
    this.startedAt,
    this.lastTickAt,
  });

  final Subject? selectedSubject;
  final bool isRunning;
  final bool isPaused;
  final int elapsedSeconds;
  final DateTime? startedAt;
  final DateTime? lastTickAt;

  TimerRunState copyWith({
    Subject? selectedSubject,
    bool clearSelectedSubject = false,
    bool? isRunning,
    bool? isPaused,
    int? elapsedSeconds,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? lastTickAt,
    bool clearLastTickAt = false,
  }) {
    return TimerRunState(
      selectedSubject:
          clearSelectedSubject ? null : (selectedSubject ?? this.selectedSubject),
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      lastTickAt: clearLastTickAt ? null : (lastTickAt ?? this.lastTickAt),
    );
  }
}

class TimerRunController extends StateNotifier<TimerRunState> {
  TimerRunController(this._ref) : super(const TimerRunState());

  final Ref _ref;
  Timer? _ticker;
  bool _stopping = false;
  DateTime? _lastSavedStartedAt;

  void selectSubject(String subjectId) {
    final current = state.selectedSubject;
    final name = current?.id == subjectId ? current!.name : '';
    state = state.copyWith(
      selectedSubject: Subject(
        id: subjectId,
        name: name,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }

  void start() {
    if (state.selectedSubject == null || state.isRunning) return;

    final now = DateTime.now();
    _lastSavedStartedAt = null;
    _cancelTicker();
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      elapsedSeconds: 0,
      startedAt: now,
      lastTickAt: now,
    );
    _startTicker();
  }

  void pause() {
    if (!state.isRunning || state.isPaused) return;

    _accumulateElapsed();
    _cancelTicker();
    state = state.copyWith(
      isPaused: true,
      lastTickAt: DateTime.now(),
    );
  }

  void resume() {
    if (!state.isRunning || !state.isPaused) return;

    final now = DateTime.now();
    state = state.copyWith(
      isPaused: false,
      lastTickAt: now,
    );
    _startTicker();
  }

  Future<void> stopAndSave() async {
    if (!state.isRunning || _stopping) return;
    _stopping = true;
    try {
      _cancelTicker();

      if (!state.isPaused) {
        _accumulateElapsed();
      }

      final now = DateTime.now();
      final selected = state.selectedSubject;
      final startedAt = state.startedAt;
      final elapsed = state.elapsedSeconds;

      state = state.copyWith(
        isRunning: false,
        isPaused: false,
        elapsedSeconds: 0,
        clearStartedAt: true,
        clearLastTickAt: true,
      );

      if (startedAt == null) return;
      if (_lastSavedStartedAt == startedAt) return;
      _lastSavedStartedAt = startedAt;

      if (selected != null && elapsed > 0) {
        final session = TimerSession(
          id: _newId(),
          subjectId: selected.id,
          startAt: startedAt,
          endAt: now,
          durationSeconds: elapsed,
        );
        try {
          await _ref.read(timerSessionsProvider.notifier).addSession(session);
        } catch (_) {
          // swallow to prevent crash
        }
      }
    } finally {
      _stopping = false;
    }
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning || state.isPaused) return;
      _accumulateElapsed();
    });
  }

  void _accumulateElapsed() {
    if (!state.isRunning || state.isPaused) return;

    final now = DateTime.now();
    final last = state.lastTickAt;
    if (last == null) {
      state = state.copyWith(lastTickAt: now);
      return;
    }

    final delta = now.difference(last).inSeconds;
    if (delta <= 0) return;

    state = state.copyWith(
      elapsedSeconds: state.elapsedSeconds + delta,
      lastTickAt: now,
    );
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String _newId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final suffix = (ts % 100000).toString().padLeft(5, '0');
    return 't_$ts$suffix';
  }

  @override
  void dispose() {
    _cancelTicker();
    super.dispose();
  }
}
