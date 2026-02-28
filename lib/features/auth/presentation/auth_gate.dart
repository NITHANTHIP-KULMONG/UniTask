import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../../dashboard/presentation/admin_home_page.dart';
import '../../tasks/presentation/user_home_page.dart';
import 'login_page.dart';

/// The root auth-gate widget — placed as [MaterialApp.home].
///
/// ## Two-stage resolution
///
///  1. **Auth state** (`authStateProvider`):
///     - `loading` → spinner (Firebase restoring session from indexedDB).
///     - `null`    → [LoginPage].
///     - `User`    → proceed to step 2.
///
///  2. **User role** (`appUserProvider`):
///     - `loading` → spinner (Firestore fetching `users/{uid}`).
///     - `null` / missing doc → friendly error (document not yet written).
///     - `admin`  → [AdminHomePage].
///     - `user`   → [HomeShell].
///
/// Because both providers are Riverpod [StreamProvider]s, their values are
/// cached and survive widget rebuilds — no flashing of the wrong page.
///
/// ## How Firebase persists sessions on Flutter Web
///
/// In [main.dart] we call `setPersistence(Persistence.LOCAL)`, which tells
/// the Firebase JS SDK to store the auth token in `indexedDB`.  When the
/// user refreshes the page:
///
///  1. The SDK reads the cached token from `indexedDB`.
///  2. It silently validates the token with the Firebase backend.
///  3. `authStateChanges()` emits the restored [User].
///
/// During step 1-2 the stream hasn't emitted yet, so [authStateProvider] is
/// in the `loading` state and we show a spinner.  Once step 3 completes,
/// `appUserProvider` fetches the role and the user lands on the correct page.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Waiting for Firebase to resolve the persisted session.
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // Stream error (very rare — e.g. network completely unavailable).
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),

      // Auth state resolved — user is either logged in or not.
      data: (user) {
        // Not authenticated → show login.
        if (user == null) return const LoginPage();

        // Authenticated → resolve role from Firestore.
        return _RoleGate();
      },
    );
  }
}

// =============================================================================
// _RoleGate (private)
// =============================================================================

/// Second-stage gate that resolves the user's Firestore role before choosing
/// which home page to show.
///
/// Separated from [AuthGate] so the `appUserProvider` stream is only watched
/// when a user is actually logged in.
class _RoleGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);

    return appUserAsync.when(
      // Firestore is still loading the user document.
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // Firestore read failed.
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load your profile.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),

      // User document resolved.
      data: (appUser) {
        // Edge case: document hasn't been written yet (first-login latency).
        // The stream will re-emit once `ensureUserDocument` completes.
        if (appUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Route based on role.
        return switch (appUser.role) {
          UserRole.admin => const AdminHomePage(),
          UserRole.user => const UserHomePage(),
        };
      },
    );
  }
}
