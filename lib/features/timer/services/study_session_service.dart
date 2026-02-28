import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../domain/study_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final studySessionServiceProvider = Provider<StudySessionService>((ref) {
  return StudySessionService(FirebaseFirestore.instance);
});

/// Real-time stream of the current user's study sessions (most recent first).
final userStudySessionsProvider = StreamProvider<List<StudySession>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(studySessionServiceProvider).userSessionsStream(uid);
});

/// Today's total study time in seconds (work sessions only).
final dailyStudySecondsProvider = Provider<int>((ref) {
  final sessions = ref.watch(userStudySessionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return sessions
      .where((s) =>
          s.sessionType == SessionType.work &&
          !s.startAt.isBefore(today) &&
          s.startAt.isBefore(tomorrow))
      .fold<int>(0, (sum, s) => sum + s.durationSeconds.clamp(0, 86400));
});

/// Today's completed Pomodoro count.
final dailyPomodoroCountProvider = Provider<int>((ref) {
  final sessions = ref.watch(userStudySessionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return sessions
      .where((s) =>
          s.sessionType == SessionType.work &&
          !s.startAt.isBefore(today) &&
          s.startAt.isBefore(tomorrow))
      .length;
});

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class StudySessionService {
  StudySessionService(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('sessions');

  /// Create a new study session document.
  Future<void> saveSession(StudySession session) {
    return _col.doc(session.id).set(session.toFirestore());
  }

  /// Delete a session by ID.
  Future<void> deleteSession(String id) => _col.doc(id).delete();

  /// Real-time stream of a user's sessions (last 50, newest first).
  Stream<List<StudySession>> userSessionsStream(String uid) {
    return _col
        .where('ownerId', isEqualTo: uid)
        .orderBy('startAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StudySession.fromFirestore(d)).toList());
  }
}
