import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_subject_repository.dart';
import '../domain/subject.dart';
import '../domain/subject_repository.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return const LocalSubjectRepository();
});

final subjectControllerProvider =
    StateNotifierProvider<SubjectController, AsyncValue<List<Subject>>>(
  (ref) => SubjectController(ref.watch(subjectRepositoryProvider)),
);

class SubjectController extends StateNotifier<AsyncValue<List<Subject>>> {
  SubjectController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final SubjectRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<void> add(Subject s) async => _mutate(() => _repository.add(s));

  Future<void> update(Subject s) async => _mutate(() => _repository.update(s));

  Future<void> deleteById(String id) async => _mutate(() => _repository.delete(id));

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      return _repository.getAll();
    });
  }
}
