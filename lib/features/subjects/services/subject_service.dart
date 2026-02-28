import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../domain/subject.dart';

// =============================================================================
// Constants
// =============================================================================

/// Maximum subjects fetched per stream / page.
const kSubjectPageSize = 50;

// =============================================================================
// Riverpod providers
// =============================================================================

/// Provides the singleton [SubjectService].
final subjectServiceProvider = Provider<SubjectService>((ref) {
  return SubjectService();
});

/// Real-time stream of the current user's subjects, ordered alphabetically.
///
/// **Firestore query:** `subjects` WHERE `ownerId == uid` ORDER BY `name` ASC
///                       LIMIT [kSubjectPageSize]
///
/// Requires composite index: (ownerId ASC, name ASC).
final userSubjectsProvider = StreamProvider<List<Subject>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(subjectServiceProvider).userSubjectsStream(user.uid);
    },
  );
});

// =============================================================================
// SubjectService
// =============================================================================

/// Firestore CRUD for the `subjects` collection.
///
/// Follows the same patterns as [TaskService]:
///  • Server timestamps on create and update.
///  • Queries scoped to the authenticated user via `ownerId`.
///  • Pagination-ready with `.limit()`.
class SubjectService {
  SubjectService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('subjects');

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Real-time stream of a user's subjects, ordered A → Z by name.
  Stream<List<Subject>> userSubjectsStream(String uid) {
    return _col
        .where('ownerId', isEqualTo: uid)
        .orderBy('name')
        .limit(kSubjectPageSize)
        .snapshots()
        .map((snap) => snap.docs.map(Subject.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Creates a new subject document with server timestamps.
  Future<void> createSubject({
    required String name,
    required String ownerId,
    SubjectColor color = SubjectColor.indigo,
  }) async {
    await _col.add({
      'name': name,
      'ownerId': ownerId,
      'color': color.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates name and/or colour of an existing subject.  Always bumps
  /// `updatedAt`.
  Future<void> updateSubject(Subject subject) async {
    await _col.doc(subject.id).update({
      'name': subject.name,
      'color': subject.color.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Permanently deletes a subject document.
  Future<void> deleteSubject(String id) async {
    await _col.doc(id).delete();
  }
}
