class TimerSession {
  final String id;
  final String subjectId;
  final DateTime startAt;
  final DateTime? endAt;
  final int durationSeconds;

  const TimerSession({
    required this.id,
    required this.subjectId,
    required this.startAt,
    this.endAt,
    required this.durationSeconds,
  });

  bool get isCompleted => endAt != null && durationSeconds > 0;

  TimerSession copyWith({
    String? id,
    String? subjectId,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    int? durationSeconds,
  }) {
    return TimerSession(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null ? null : DateTime.parse(json['endAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
