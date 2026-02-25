import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_assignment_repository.dart';
import '../domain/assignment.dart';
import '../domain/assignment_repository.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return const LocalAssignmentRepository();
});

final assignmentControllerProvider =
    StateNotifierProvider<AssignmentController, AsyncValue<List<Assignment>>>(
  (ref) => AssignmentController(ref.watch(assignmentRepositoryProvider)),
);

class AssignmentController extends StateNotifier<AsyncValue<List<Assignment>>> {
  AssignmentController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final AssignmentRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<void> add(Assignment a) async => _mutate(() => _repository.add(a));

  Future<void> update(Assignment a) async => _mutate(() => _repository.update(a));

  Future<void> deleteById(String id) async => _mutate(() => _repository.delete(id));

  Future<void> toggleDone(String id) async {
    final assignments = state.valueOrNull ?? await _repository.getAll();
    final idx = assignments.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final target = assignments[idx];
    final next = target.copyWith(isDone: !target.isDone);
    await _mutate(() => _repository.update(next));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      return _repository.getAll();
    });
  }
}