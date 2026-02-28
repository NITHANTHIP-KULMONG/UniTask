import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String ownerId;
  final String subjectId;
  final String title;
  final DateTime dueDate;
  final double weightPercent;
  final bool isDone;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.ownerId,
    required this.subjectId,
    required this.title,
    required this.dueDate,
    required this.weightPercent,
    required this.isDone,
    required this.createdAt,
  });

  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  Assignment copyWith({
    String? id,
    String? ownerId,
    String? subjectId,
    String? title,
    DateTime? dueDate,
    double? weightPercent,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      weightPercent: weightPercent ?? this.weightPercent,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'subjectId': subjectId,
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'weightPercent': weightPercent,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Assignment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Assignment(
      id: doc.id,
      ownerId: d['ownerId'] as String? ?? '',
      subjectId: d['subjectId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      dueDate: (d['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weightPercent: (d['weightPercent'] as num?)?.toDouble() ?? 0,
      isDone: d['isDone'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assignment &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.subjectId == subjectId &&
        other.title == title &&
        other.dueDate == dueDate &&
        other.weightPercent == weightPercent &&
        other.isDone == isDone &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        ownerId,
        subjectId,
        title,
        dueDate,
        weightPercent,
        isDone,
        createdAt,
      );
}
