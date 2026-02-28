import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/assignment.dart';
import '../services/assignment_service.dart';

// Re-export so screens only need one import.
export '../services/assignment_service.dart'
    show assignmentServiceProvider, userAssignmentsProvider;

/// Provides an [AssignmentController] for imperative write operations.
///
/// The real-time list comes from [userAssignmentsProvider] (a StreamProvider
/// backed by Firestore). This controller only handles mutations.
final assignmentControllerProvider =
    Provider<AssignmentController>((ref) {
  return AssignmentController(ref.read(assignmentServiceProvider));
});

/// Thin command layer over [AssignmentService].
class AssignmentController {
  AssignmentController(this._service);
  final AssignmentService _service;

  Future<void> add(Assignment assignment) => _service.createAssignment(assignment);

  Future<void> update(Assignment assignment) => _service.updateAssignment(assignment);

  Future<void> deleteById(String id) => _service.deleteAssignment(id);

  Future<void> toggleDone(String id, bool currentValue) =>
      _service.toggleDone(id, currentValue);
}