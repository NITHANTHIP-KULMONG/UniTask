import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

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
    error: (error, stackTrace) => const Stream.empty(),
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

  CollectionReference<Map<String, dynamic>> get _mailCol =>
      _firestore.collection('mail');

  DocumentReference<Map<String, dynamic>> _otpDocRef({
    required String uid,
    required String action,
  }) {
    return _usersCol.doc(uid).collection('otps').doc(action);
  }

  final Random _random = Random.secure();

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

    // Ensure profile document exists for accounts created before this flow.
    await ensureUserDocument(user);

    // Update Firestore user document
    await _usersCol.doc(user.uid).set({
      'name': newName,
    }, SetOptions(merge: true));
  }

  /// Updates profile photo in both Firebase Auth and Firestore.
  Future<void> updatePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updatePhotoURL(photoUrl);

    // Ensure profile document exists before merge-write.
    await ensureUserDocument(user);

    await _usersCol.doc(user.uid).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Refresh in-memory auth user so consumers see the latest profile quickly.
    await user.reload();
  }

  // ---------------------------------------------------------------------------
  // Credential flows
  // ---------------------------------------------------------------------------

  /// Sends a Firebase reset-password email.
  ///
  /// This is the secure password-change flow for end users.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Sends a 6-digit OTP to the current account email for password change.
  ///
  /// This requires the user to re-authenticate with [currentPassword].
  Future<void> sendPasswordChangeCode({
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated user found.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Current account email is missing.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    final code = _generateCode();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    await _otpDocRef(uid: user.uid, action: 'password_change').set({
      'code': code,
      'action': 'password_change',
      'targetEmail': email,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'attempts': 0,
    });

    await _sendOtpEmail(
      to: email,
      code: code,
      actionLabel: 'password change',
    );
  }

  /// Verifies a 6-digit OTP and updates password.
  Future<void> confirmPasswordChangeCode({
    required String code,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated user found.',
      );
    }

    final docRef = _otpDocRef(uid: user.uid, action: 'password_change');
    final snap = await docRef.get();

    if (!snap.exists || snap.data() == null) {
      throw FirebaseAuthException(
        code: 'code-not-found',
        message: 'Verification code not found. Please request a new one.',
      );
    }

    final data = snap.data()!;
    _validateOtp(data, code);

    await user.updatePassword(newPassword);
    await docRef.delete();
  }

  /// Sends a 6-digit OTP to [newEmail] for email change.
  ///
  /// This requires current password re-authentication.
  Future<void> sendEmailChangeCode({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated user found.',
      );
    }

    final oldEmail = user.email;
    if (oldEmail == null || oldEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Current account email is missing.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: oldEmail,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    final code = _generateCode();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    await _otpDocRef(uid: user.uid, action: 'email_change').set({
      'code': code,
      'action': 'email_change',
      'targetEmail': newEmail.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'attempts': 0,
    });

    await _sendOtpEmail(
      to: newEmail.trim(),
      code: code,
      actionLabel: 'email change',
    );
  }

  /// Verifies a 6-digit OTP and updates account email.
  Future<void> confirmEmailChangeCode({
    required String code,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated user found.',
      );
    }

    final docRef = _otpDocRef(uid: user.uid, action: 'email_change');
    final snap = await docRef.get();

    if (!snap.exists || snap.data() == null) {
      throw FirebaseAuthException(
        code: 'code-not-found',
        message: 'Verification code not found. Please request a new one.',
      );
    }

    final data = snap.data()!;
    _validateOtp(data, code);

    final targetEmail = (data['targetEmail'] as String?)?.trim();
    if (targetEmail == null || targetEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-target-email',
        message: 'Target email was not found in the verification request.',
      );
    }

    // ignore: deprecated_member_use
    await user.updateEmail(targetEmail);
    await _usersCol.doc(user.uid).set(
      {'email': targetEmail},
      SetOptions(merge: true),
    );
    await docRef.delete();
  }

  /// Re-authenticates with current password and sends verification to [newEmail].
  ///
  /// The email is not changed until the user confirms the verification link.
  Future<void> sendEmailChangeVerification({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated user found.',
      );
    }

    final oldEmail = user.email;
    if (oldEmail == null || oldEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Current account email is missing.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: oldEmail,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  void _validateOtp(Map<String, dynamic> data, String inputCode) {
    final savedCode = (data['code'] as String?) ?? '';
    final expiresTs = data['expiresAt'];
    final expiresAt = expiresTs is Timestamp ? expiresTs.toDate() : null;

    if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      throw FirebaseAuthException(
        code: 'code-expired',
        message: 'Verification code has expired. Please request a new one.',
      );
    }

    if (savedCode != inputCode.trim()) {
      throw FirebaseAuthException(
        code: 'invalid-code',
        message: 'Verification code is invalid.',
      );
    }
  }

  String _generateCode() {
    final value = _random.nextInt(1000000);
    return value.toString().padLeft(6, '0');
  }

  Future<void> _sendOtpEmail({
    required String to,
    required String code,
    required String actionLabel,
  }) async {
    await _mailCol.add({
      'to': [to],
      'message': {
        'subject': 'UniTask verification code',
        'text':
            'Your UniTask 6-digit code for $actionLabel is: $code\n\nThis code will expire in 10 minutes. If you did not request this, please ignore this email.',
      },
    });
  }

  // ---------------------------------------------------------------------------
  // Delete account
  // ---------------------------------------------------------------------------

  /// Permanently deletes the user's account.
  ///
  /// 1. Deletes the Firebase Auth account.
  /// 2. Best-effort deletes the Firestore user document.
  ///
  /// **Note:** Firebase Auth may throw `requires-recent-login` if the user
  /// hasn't signed in recently. The caller should handle re-authentication.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Delete auth account first so failures (e.g. requires-recent-login)
    // do not leave the app in a half-deleted state.
    await user.delete();

    // Best effort cleanup of Firestore profile document.
    try {
      await _usersCol.doc(uid).delete();
    } catch (_) {
      // Ignore cleanup failures here; account deletion already succeeded.
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Signs the current user out.  The [authStateChanges] stream will emit
  /// `null`, causing [AuthGate] to flip back to the login page.
  Future<void> signOut() => _auth.signOut();
}
