import 'package:cloud_firestore/cloud_firestore.dart';

// =============================================================================
// TaskStatus enum
// =============================================================================

/// Represents the lifecycle of a task.
///
/// Stored as a lowercase string in Firestore (`"todo"`, `"doing"`, `"done"`).
enum TaskStatus {
  todo,
  doing,
  done;

  /// Display label for the UI.
  String get label => switch (this) {
        TaskStatus.todo => 'To Do',
        TaskStatus.doing => 'Doing',
        TaskStatus.done => 'Done',
      };

  /// Parses a Firestore string back into the enum.
  /// Defaults to [TaskStatus.todo] for unknown or null values.
  factory TaskStatus.fromString(String? value) {
    return switch (value) {
      'doing' => TaskStatus.doing,
      'done' => TaskStatus.done,
      _ => TaskStatus.todo,
    };
  }
}

// =============================================================================
// Task model
// =============================================================================

/// Mirrors a `tasks/{id}` Firestore document.
///
/// The [ownerId] field links the task to a user - security rules enforce
/// that only the owner (or an admin) can read / write each document.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.isCompleted,
    required this.userId,
    required this.subjectId,
    required this.status,
    this.dueDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;
  final String subjectId;
  final TaskStatus status;
  final DateTime? dueDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Task.fromJson(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Task.fromJson(Map<String, dynamic> json, {String? id}) {
    final created = _toDateTime(json['createdAt']) ?? DateTime.now();
    final status = TaskStatus.fromString(json['status'] as String?);
    final completed =
        (json['isCompleted'] as bool?) ?? status == TaskStatus.done;

    return Task(
      id: id ?? (json['id'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: completed,
      userId: json['ownerId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      status: status,
      dueDateTime: _normalizeDueDateTime(
        _toDateTime(json['dueDateTime'] ?? json['dueDate']),
      ),
      createdAt: created,
      updatedAt: _toDateTime(json['updatedAt']) ?? created,
    );
  }

  /// For creating / updating a document. Does NOT include `id` - that's the
  /// document key, not a field.
  Map<String, dynamic> toJson() {
    final normalizedStatus = isCompleted ? TaskStatus.done : status;
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'ownerId': userId,
      'subjectId': subjectId,
      'status': normalizedStatus.name,
      'dueDateTime':
          dueDateTime == null ? null : Timestamp.fromDate(dueDateTime!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  /// Convenience copy method for status and metadata changes.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? userId,
    String? subjectId,
    TaskStatus? status,
    DateTime? dueDateTime,
    bool clearDueDateTime = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      status: status ?? this.status,
      dueDateTime: clearDueDateTime ? null : (dueDateTime ?? this.dueDateTime),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _normalizeDueDateTime(DateTime? value) {
    if (value == null) return null;

    final hasTime = value.hour != 0 ||
        value.minute != 0 ||
        value.second != 0 ||
        value.millisecond != 0 ||
        value.microsecond != 0;

    if (hasTime) return value;
    return DateTime(value.year, value.month, value.day, 18, 0);
  }

  static DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
