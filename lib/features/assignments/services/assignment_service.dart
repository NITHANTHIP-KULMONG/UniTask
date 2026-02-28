import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../domain/assignment.dart';

// =============================================================================
// Providers
// =============================================================================

final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  return AssignmentService(FirebaseFirestore.instance);
});

/// Real-time stream of the current user's assignments (newest first).
final userAssignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(assignmentServiceProvider).userAssignmentsStream(uid);
});

/// Real-time stream of ALL assignments (admin view).
final allAssignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  return ref.read(assignmentServiceProvider).allAssignmentsStream();
});

// =============================================================================
// Service
// =============================================================================

class AssignmentService {
  AssignmentService(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('assignments');

  /// Real-time stream of assignments for a single user, newest first.
  Stream<List<Assignment>> userAssignmentsStream(String uid) {
    return _col
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Assignment.fromFirestore).toList());
  }

  /// Real-time stream of ALL assignments (admin view).
  Stream<List<Assignment>> allAssignmentsStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(Assignment.fromFirestore).toList());
  }

  /// Create a new assignment document.
  Future<void> createAssignment(Assignment assignment) async {
    await _col.add(assignment.toFirestore());
  }

  /// Update an existing assignment.
  Future<void> updateAssignment(Assignment assignment) async {
    await _col.doc(assignment.id).update(assignment.toFirestore());
  }

  /// Delete an assignment by ID.
  Future<void> deleteAssignment(String id) async {
    await _col.doc(id).delete();
  }

  /// Toggle the isDone flag on an assignment.
  Future<void> toggleDone(String id, bool currentValue) async {
    await _col.doc(id).update({'isDone': !currentValue});
  }
}
