import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/subject.dart';
import '../services/subject_service.dart';

// Re-export so screens only need one import.
export '../services/subject_service.dart'
    show subjectServiceProvider, userSubjectsProvider;

/// Provides a [SubjectController] for imperative write operations
/// (add / rename / delete).
///
/// The real-time list comes from [userSubjectsProvider] (a StreamProvider
/// backed by Firestore).  This controller only handles mutations.
final subjectControllerProvider =
    Provider<SubjectController>((ref) {
  return SubjectController(ref.read(subjectServiceProvider));
});

/// Thin command layer over [SubjectService].
///
/// Screens call these methods for writes; reads come from
/// [userSubjectsProvider].
class SubjectController {
  SubjectController(this._service);

  final SubjectService _service;

  Future<void> add({
    required String name,
    required String ownerId,
    SubjectColor color = SubjectColor.indigo,
  }) =>
      _service.createSubject(name: name, ownerId: ownerId, color: color);

  Future<void> update(Subject subject) => _service.updateSubject(subject);

  Future<void> deleteById(String id) => _service.deleteSubject(id);
}
