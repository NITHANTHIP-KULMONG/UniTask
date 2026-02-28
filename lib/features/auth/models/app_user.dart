import 'package:cloud_firestore/cloud_firestore.dart';

// =============================================================================
// UserRole enum
// =============================================================================

/// The two roles in the system. Stored as a plain string in Firestore.
///
/// **Default:** Every new user is created with [UserRole.user].
/// Promotion to [UserRole.admin] must happen server-side (Firebase Console,
/// Cloud Function, or Admin SDK) — never from the client UI.
enum UserRole {
  user,
  admin;

  /// Parses a Firestore string back into the enum.
  /// Falls back to [UserRole.user] for unknown / null values — defensive
  /// coding so a corrupted document never crashes the app.
  factory UserRole.fromString(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      _ => UserRole.user,
    };
  }
}

// =============================================================================
// AppUser model
// =============================================================================

/// Lightweight model that mirrors the `users/{uid}` Firestore document.
///
/// This is deliberately separate from [firebase_auth.User] because:
///  • Firebase Auth only stores identity data (email, display name, photo).
///  • App-specific data (role, preferences, etc.) lives in Firestore.
///  • Keeping a dedicated model lets us extend it later without touching auth.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;

  /// Whether this user has admin privileges.
  bool get isAdmin => role == UserRole.admin;

  // ---------------------------------------------------------------------------
  // Firestore serialisation
  // ---------------------------------------------------------------------------

  /// Creates an [AppUser] from a Firestore document snapshot.
  ///
  /// Uses null-aware defaults so partially-written documents don't crash.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.fromString(data['role'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts to a Firestore-compatible map for writes.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.name, // "user" or "admin"
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
