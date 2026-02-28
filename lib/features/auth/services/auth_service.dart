import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

// =============================================================================
// Riverpod providers
// =============================================================================

/// Provides the singleton [AuthService] to the widget tree.
///
///   ref.read(authServiceProvider).signIn(...)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Exposes Firebase auth state as a Riverpod [StreamProvider].
///
/// Why a StreamProvider instead of a raw StreamBuilder?
///  • The stream is created once and cached by Riverpod — it survives widget
///    rebuilds, so we never get a "flash of LoginPage" on hot-reload or
///    navigation rebuilds.
///  • Widgets simply call `ref.watch(authStateProvider)` and get an
///    [AsyncValue<User?>] with built-in loading / error / data states.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Streams the [AppUser] document for the currently authenticated user.
///
/// **How it works:**
///  1. Watches [authStateProvider] — if the user is null (logged out), emits
///     `null` immediately.
///  2. When a [User] is present, listens to `users/{uid}` in Firestore via
///     `snapshots()`.  Any server-side role change (e.g. promoted to admin)
///     is reflected in real time — no manual refresh needed.
///
/// **Why a StreamProvider?**
///  • Riverpod caches it, so multiple widgets watching the role don't create
///    duplicate Firestore listeners.
///  • The `.when()` API gives free loading / error states in the UI.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.read(authServiceProvider).userDocStream(user.uid);
    },
  );
});

/// Streams ALL user documents. Only used by the admin dashboard.
///
/// Firestore security rules restrict this to users with `role == "admin"`.
/// A non-admin calling this will get a permission-denied error.
final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(authServiceProvider).allUsersStream();
});

// =============================================================================
// AuthService
// =============================================================================

/// A thin wrapper around [FirebaseAuth] and Firestore user documents.
///
/// **Why separate service and UI?**
///  • UI widgets stay declarative — they call [signIn] / [signUp] / [signOut]
///    without knowing *how* Firebase works internally.
///  • Swapping providers (e.g. adding Google sign-in) means editing only this
///    class, not every page that calls Firebase.
///  • Unit-testing is easy: inject a mock [FirebaseAuth] via the constructor.
class AuthService {
  /// Accepts optional [FirebaseAuth] and [FirebaseFirestore] for testability.
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Reference to the `users` collection — single source of truth.
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // Auth state
  // ---------------------------------------------------------------------------

  /// The single source of truth for login state.
  ///
  /// **Why `authStateChanges()` and not manual tracking?**
  ///  • Firebase handles token refresh, session expiry, and cross-tab state
  ///    automatically.  Subscribing to this stream means the UI always reflects
  ///    the real auth state without any manual bookkeeping.
  ///  • On Flutter Web with `Persistence.LOCAL`, the stream re-emits the
  ///    persisted user on page refresh — no extra code needed.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Synchronous check for the currently cached user (may be null).
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Sign in
  // ---------------------------------------------------------------------------

  /// Signs in with [email] and [password], then ensures the Firestore
  /// user document exists.
  ///
  /// Throws [FirebaseAuthException] on failure.  The UI should catch it and
  /// display a user-friendly message based on [FirebaseAuthException.code].
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await ensureUserDocument(credential.user!);
    }
    return credential;
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  /// Creates a new account, signs in immediately, and creates the
  /// Firestore user document with the default role.
  ///
  /// Common error codes: `weak-password`, `email-already-in-use`,
  /// `invalid-email`.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await ensureUserDocument(credential.user!);
    }
    return credential;
  }

  // ---------------------------------------------------------------------------
  // Google sign-in (Web)
  // ---------------------------------------------------------------------------

  /// Signs in with a Google popup on Flutter Web.
  ///
  /// **Why `signInWithPopup` instead of `signInWithRedirect`?**
  ///  • Popup keeps the SPA state intact — no full-page reload.
  ///  • The returned [UserCredential] gives immediate access to display name,
  ///    email, and photo URL via `credential.user`.
  ///  • If the popup is blocked by the browser, [FirebaseAuthException] is
  ///    thrown with code `popup-blocked`.
  ///
  /// **Scopes:** We request `email` and `profile` (the defaults).  Add more
  /// scopes to the [GoogleAuthProvider] if you need calendar, drive, etc.
  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    // Default scopes already include email & profile.
    final credential = await _auth.signInWithPopup(provider);
    if (credential.user != null) {
      await ensureUserDocument(credential.user!);
    }
    return credential;
  }

  // ---------------------------------------------------------------------------
  // Firestore user document
  // ---------------------------------------------------------------------------

  /// Ensures a `users/{uid}` document exists for [user].
  ///
  /// **Called once after every successful sign-in** (email or Google).
  /// Uses a Firestore `get()` check — NOT `set(merge: true)` — so that
  /// existing documents (and their server-set role) are never overwritten.
  ///
  /// **Why not run on every `authStateChanges` emission?**
  ///  • `authStateChanges` also fires on token refresh and page reload.
  ///    Re-writing the document on every emit would be wasteful and could
  ///    race with admin role changes.
  ///  • Instead, the sign-in methods call this explicitly after success.
  Future<void> ensureUserDocument(User user) async {
    final docRef = _usersCol.doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
        'role': 'user', // default — promotion happens server-side only
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Real-time stream of the [AppUser] document for a given [uid].
  ///
  /// Returns `null` if the document doesn't exist yet (edge case during
  /// first-login write latency).
  Stream<AppUser?> userDocStream(String uid) {
    return _usersCol.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromFirestore(snap);
    });
  }

  /// Real-time stream of ALL user documents (admin use only).
  Stream<List<AppUser>> allUsersStream() {
    return _usersCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppUser.fromFirestore).toList());
  }

  // ---------------------------------------------------------------------------
  // Profile updates
  // ---------------------------------------------------------------------------

  /// Updates the display name in both Firebase Auth and the Firestore user doc.
  ///
  /// After calling this, [appUserProvider] will automatically re-emit the
  /// updated [AppUser] because we're writing to the same `users/{uid}`
  /// document that the stream watches.
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Update Firebase Auth profile
    await user.updateDisplayName(newName);

    // Update Firestore user document
    await _usersCol.doc(user.uid).update({'name': newName});
  }

  // ---------------------------------------------------------------------------
  // Delete account
  // ---------------------------------------------------------------------------

  /// Permanently deletes the user's account.
  ///
  /// 1. Deletes the Firestore user document.
  /// 2. Deletes the Firebase Auth account.
  ///
  /// **Note:** Firebase Auth may throw `requires-recent-login` if the user
  /// hasn't signed in recently. The caller should handle re-authentication.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete Firestore user doc first (auth deletion removes the token)
    await _usersCol.doc(user.uid).delete();

    // Delete the Firebase Auth account
    await user.delete();
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Signs the current user out.  The [authStateChanges] stream will emit
  /// `null`, causing [AuthGate] to flip back to the login page.
  Future<void> signOut() => _auth.signOut();
}
