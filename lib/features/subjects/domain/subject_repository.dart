import 'subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getAll();

  Future<void> saveAll(List<Subject> subjects);

  Future<void> add(Subject subject);

  Future<void> update(Subject subject);

  Future<void> delete(String id);
}
