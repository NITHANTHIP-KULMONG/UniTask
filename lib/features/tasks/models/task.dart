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
/// The [ownerId] field links the task to a user — security rules enforce
/// that only the owner (or an admin) can read / write each document.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String ownerId;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Firestore serialisation
  // ---------------------------------------------------------------------------

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final created =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Task(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      status: TaskStatus.fromString(data['status'] as String?),
      createdAt: created,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? created,
    );
  }

  /// For creating / updating a document. Does NOT include `id` — that's the
  /// document key, not a field.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convenience copy method for status changes.
  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
