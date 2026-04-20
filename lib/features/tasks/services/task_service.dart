import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../models/task.dart';
import 'notification_service.dart';

// =============================================================================
// Constants
// =============================================================================

/// Default page size for paginated queries.
///
/// 20 is a sweet spot: small enough for fast Firestore reads, large enough
/// that users rarely need to paginate on a typical dashboard.
const int kTaskPageSize = 20;

// =============================================================================
// Riverpod providers
// =============================================================================

/// Provides the singleton [TaskService] to the widget tree.
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

/// Streams the current user's tasks, ordered by creation date (newest first).
///
/// Returns an empty list when the user is not authenticated.
/// The stream updates in real time - any Firestore write (create, update,
/// delete) is reflected instantly in the UI without manual refresh.
///
/// Uses `.limit(kTaskPageSize)` - the UI can call [TaskService.userTasksPaged]
/// for explicit cursor-based pagination when needed.
final userTasksProvider = StreamProvider<List<Task>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(taskServiceProvider).userTasksStream(user.uid);
    },
  );
});

/// Streams ALL tasks across all users. Only used by admin pages.
///
/// Firestore security rules restrict reads to admins only - a non-admin will
/// get a permission error that surfaces through the stream's error state.
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.read(taskServiceProvider).allTasksStream();
});

// =============================================================================
// TaskService
// =============================================================================

/// CRUD wrapper for the `tasks` Firestore collection.
///
/// Each task document has an `ownerId` field linking it to the creating user.
/// Security rules ensure users can only touch their own tasks, while admins
/// can read everything.
///
/// ## Query patterns & indexes
///
/// | Query                                        | Index required                                |
/// |----------------------------------------------|-----------------------------------------------|
/// | `ownerId == uid` + `orderBy createdAt desc`  | Composite: (ownerId ASC, createdAt DESC)      |
/// | `ownerId == uid` + `status == x` + `orderBy` | Composite: (ownerId ASC, status ASC, createdAt DESC) |
/// | `status == x` + `orderBy updatedAt desc`     | Composite: (status ASC, updatedAt DESC)       |
///
/// All indexes are defined in `firestore.indexes.json` and deployed via
/// `firebase deploy --only firestore:indexes`.
class TaskService {
  TaskService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationService =
            notificationService ?? NotificationService.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService;

  CollectionReference<Map<String, dynamic>> get _tasksCol =>
      _firestore.collection('tasks');

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  /// Creates a new task for the currently authenticated user.
  ///
  /// `dueDateTime` is optional and stored as a Firestore [Timestamp] when present.
  /// Both `createdAt` and `updatedAt` use server timestamps so they are
  /// consistent regardless of client clock skew.
  Future<DocumentReference<Map<String, dynamic>>> createTask({
    required String title,
    required String description,
    required String subjectId,
    DateTime? dueDateTime,
  }) async {
    final ownerId = _auth.currentUser?.uid;
    if (ownerId == null || ownerId.isEmpty) {
      throw StateError('Cannot create task without an authenticated user.');
    }

    final createdRef = await _tasksCol.add({
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'subjectId': subjectId,
      'isCompleted': false,
      'status': TaskStatus.todo.name,
      'dueDateTime': dueDateTime == null
          ? null
          : Timestamp.fromDate(_normalizeDueDateTime(dueDateTime)),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _syncTaskNotification(
      taskId: createdRef.id,
      dueDateTime:
          dueDateTime == null ? null : _normalizeDueDateTime(dueDateTime),
      status: TaskStatus.todo,
      isCompleted: false,
    );

    return createdRef;
  }

  // ---------------------------------------------------------------------------
  // Read - real-time streams (first page)
  // ---------------------------------------------------------------------------

  /// Real-time stream of tasks for a single user, newest first.
  ///
  /// **Index:** `(ownerId ASC, createdAt DESC)` - Firestore cannot satisfy
  /// a `where` + `orderBy` on different fields without a composite index.
  /// Without it you'd get a runtime error on the first query.
  Stream<List<Task>> userTasksStream(String uid) {
    return _tasksCol
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(kTaskPageSize)
        .snapshots()
        .map((snap) => snap.docs.map(Task.fromFirestore).toList());
  }

  /// Real-time stream of ALL tasks (admin view), newest first.
  ///
  /// No equality filter -> single-field index on `createdAt` suffices (auto-
  /// created by Firestore).
  Stream<List<Task>> allTasksStream() {
    return _tasksCol
        .orderBy('createdAt', descending: true)
        .limit(kTaskPageSize)
        .snapshots()
        .map((snap) => snap.docs.map(Task.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Read - cursor-based pagination (Futures)
  // ---------------------------------------------------------------------------

  /// Fetches the next page of tasks for [uid] **after** [lastDoc].
  ///
  /// Pass `null` for [lastDoc] to get the first page. The caller stores the
  /// last [DocumentSnapshot] from the returned list and passes it back to
  /// fetch the next page.
  ///
  /// **Why `startAfterDocument` instead of `startAfter([value])`?**
  ///  - `startAfterDocument` uses Firestore's internal cursor - it is immune
  ///    to duplicate `createdAt` values and is the recommended approach.
  Future<List<Task>> userTasksPaged(
    String uid, {
    DocumentSnapshot? lastDoc,
  }) async {
    Query<Map<String, dynamic>> query = _tasksCol
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(kTaskPageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.get();
    return snap.docs.map(Task.fromFirestore).toList();
  }

  /// Fetches tasks by status for a user.
  ///
  /// **Index:** `(ownerId ASC, status ASC, createdAt DESC)`.
  Stream<List<Task>> userTasksByStatus(String uid, TaskStatus status) {
    return _tasksCol
        .where('ownerId', isEqualTo: uid)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .limit(kTaskPageSize)
        .snapshots()
        .map((snap) => snap.docs.map(Task.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Updates arbitrary fields on a task document.
  ///
  /// Converts `dueDateTime: DateTime` into Firestore [Timestamp] automatically.
  /// Always writes `updatedAt` so the composite index
  /// `(status ASC, updatedAt DESC)` stays useful for "recently changed" views.
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    final normalized = Map<String, dynamic>.from(data);

    if (normalized.containsKey('dueDate') &&
        !normalized.containsKey('dueDateTime')) {
      normalized['dueDateTime'] = normalized.remove('dueDate');
    }

    final docRef = _tasksCol.doc(taskId);
    final snapshot = await docRef.get();
    final snapshotData = snapshot.data();
    final existingTask = snapshotData == null
        ? null
        : Task.fromJson(snapshotData, id: snapshot.id);

    final containsDueDateTime = normalized.containsKey('dueDateTime');
    final dueDateTimeValue = normalized['dueDateTime'];
    if (dueDateTimeValue is DateTime) {
      normalized['dueDateTime'] =
          Timestamp.fromDate(_normalizeDueDateTime(dueDateTimeValue));
    }

    final extractedDueDateTime = _extractDateTime(dueDateTimeValue);
    final nextDueDateTime = containsDueDateTime
        ? (extractedDueDateTime == null
            ? null
            : _normalizeDueDateTime(extractedDueDateTime))
        : existingTask?.dueDateTime;
    final nextStatus = normalized.containsKey('status')
        ? TaskStatus.fromString(normalized['status'] as String?)
        : (existingTask?.status ?? TaskStatus.todo);
    final nextIsCompleted = ((normalized.containsKey('isCompleted')
                ? normalized['isCompleted'] as bool?
                : existingTask?.isCompleted) ??
            false) ||
        nextStatus == TaskStatus.done;

    await docRef.update({
      ...normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _syncTaskNotification(
      taskId: taskId,
      dueDateTime: nextDueDateTime,
      status: nextStatus,
      isCompleted: nextIsCompleted,
    );
  }

  /// Convenience: update only the status.
  Future<void> updateStatus(String taskId, TaskStatus status) {
    return updateTask(taskId, {
      'status': status.name,
      'isCompleted': status == TaskStatus.done,
    });
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deleteTask(String taskId) async {
    await _notificationService.cancelNotification(taskId.hashCode);
    await _tasksCol.doc(taskId).delete();
  }

  Future<void> restoreTask(Task task) async {
    final ownerId = _auth.currentUser?.uid;
    if (ownerId == null || ownerId.isEmpty) return;

    await _tasksCol.doc(task.id).set({
      'title': task.title,
      'description': task.description,
      'ownerId': ownerId,
      'subjectId': task.subjectId,
      'isCompleted': task.isCompleted,
      'status': task.status.name,
      'dueDateTime': task.dueDateTime == null
          ? null
          : Timestamp.fromDate(_normalizeDueDateTime(task.dueDateTime!)),
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _syncTaskNotification(
      taskId: task.id,
      dueDateTime: task.dueDateTime == null
          ? null
          : _normalizeDueDateTime(task.dueDateTime!),
      status: task.status,
      isCompleted: task.isCompleted,
    );
  }

  Future<void> _syncTaskNotification({
    required String taskId,
    required DateTime? dueDateTime,
    required TaskStatus status,
    required bool isCompleted,
  }) async {
    final notificationId = taskId.hashCode;

    if (dueDateTime == null || isCompleted || status == TaskStatus.done) {
      await _notificationService.cancelNotification(notificationId);
      return;
    }

    await _notificationService.scheduleTaskReminder(
      id: notificationId,
      dueDateTime: dueDateTime,
      title: 'Task Reminder',
      body: 'Your task is due soon',
      reminderOffset: const Duration(hours: 1),
    );
  }

  DateTime _normalizeDueDateTime(DateTime value) {
    final hasTime = value.hour != 0 ||
        value.minute != 0 ||
        value.second != 0 ||
        value.millisecond != 0 ||
        value.microsecond != 0;

    if (hasTime) return value;
    return DateTime(value.year, value.month, value.day, 18, 0);
  }

  DateTime? _extractDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
