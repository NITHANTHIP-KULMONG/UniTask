import 'assignment.dart';

abstract class AssignmentRepository {
  Future<List<Assignment>> getAll();

  Future<void> saveAll(List<Assignment> assignments);

  Future<void> add(Assignment assignment);

  Future<void> update(Assignment assignment);

  Future<void> delete(String id);
}
