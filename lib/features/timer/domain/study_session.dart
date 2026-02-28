import 'package:cloud_firestore/cloud_firestore.dart';

/// The type of Pomodoro interval.
enum SessionType {
  work('Work'),
  shortBreak('Short Break'),
  longBreak('Long Break');

  const SessionType(this.label);
  final String label;
}

/// A single completed Pomodoro study session stored in Firestore.
///
/// Designed for analytics: every session captures its [ownerId], the linked
/// [subjectId], timing data, [sessionType], and which [pomodoroNumber] it was
/// in the current cycle.
class StudySession {
  final String id;
  final String ownerId;
  final String subjectId;
  final DateTime startAt;
  final DateTime endAt;
  final int durationSeconds;
  final SessionType sessionType;
  final int pomodoroNumber;
  final DateTime createdAt;

  const StudySession({
    required this.id,
    required this.ownerId,
    required this.subjectId,
    required this.startAt,
    required this.endAt,
    required this.durationSeconds,
    required this.sessionType,
    required this.pomodoroNumber,
    required this.createdAt,
  });

  // ── Firestore serialisation ──────────────────────────────────────

  factory StudySession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StudySession(
      id: doc.id,
      ownerId: d['ownerId'] as String,
      subjectId: d['subjectId'] as String,
      startAt: (d['startAt'] as Timestamp).toDate(),
      endAt: (d['endAt'] as Timestamp).toDate(),
      durationSeconds: d['durationSeconds'] as int,
      sessionType: SessionType.values.firstWhere(
        (t) => t.name == d['sessionType'],
        orElse: () => SessionType.work,
      ),
      pomodoroNumber: (d['pomodoroNumber'] as num?)?.toInt() ?? 1,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerId': ownerId,
        'subjectId': subjectId,
        'startAt': Timestamp.fromDate(startAt),
        'endAt': Timestamp.fromDate(endAt),
        'durationSeconds': durationSeconds,
        'sessionType': sessionType.name,
        'pomodoroNumber': pomodoroNumber,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  StudySession copyWith({
    String? id,
    String? ownerId,
    String? subjectId,
    DateTime? startAt,
    DateTime? endAt,
    int? durationSeconds,
    SessionType? sessionType,
    int? pomodoroNumber,
    DateTime? createdAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      subjectId: subjectId ?? this.subjectId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sessionType: sessionType ?? this.sessionType,
      pomodoroNumber: pomodoroNumber ?? this.pomodoroNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
