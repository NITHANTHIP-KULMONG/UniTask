import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../services/auth_service.dart';
import 'register_page.dart';

/// Email + password login page.
///
/// All Firebase logic is delegated to [AuthService] — this widget only handles
/// UI state (loading flag, validation, error display).
///
/// On successful sign-in, [AuthGate] reacts to the `authStateChanges` stream
/// and swaps this page for [HomeShell].  No manual navigation needed.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Google sign-in handler
  // ---------------------------------------------------------------------------

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // AuthGate handles navigation on success.
    } on FirebaseAuthException catch (e) {
      _showError(_mapGoogleErrorCode(e.code));
    } catch (_) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Email sign-in handler
  // ---------------------------------------------------------------------------

  Future<void> _handleSignIn() async {
    // Validate the form (email format + password length).
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Delegate to AuthService — UI never touches FirebaseAuth directly.
      await ref.read(authServiceProvider).signIn(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
      // AuthGate handles navigation on success.
    } on FirebaseAuthException catch (e) {
      _showError(_mapErrorCode(e.code));
    } catch (_) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Translates Firebase error codes into readable messages.
  String _mapErrorCode(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'invalid-credential' =>
        'Invalid credentials. Check your email and password.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      _ => 'Login failed ($code). Please try again.',
    };
  }

  /// Translates Google sign-in error codes into readable messages.
  String _mapGoogleErrorCode(String code) {
    return switch (code) {
      'popup-blocked' =>
        'Sign-in popup was blocked. Please allow popups for this site.',
      'popup-closed-by-user' => 'Sign-in was cancelled.',
      'cancelled-popup-request' => 'Sign-in was cancelled.',
      'account-exists-with-different-credential' =>
        'An account already exists with this email using a different sign-in method.',
      'user-disabled' => 'This account has been disabled.',
      _ => 'Google sign-in failed ($code). Please try again.',
    };
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App title
            Text(
              'Welcome to UniTask',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Email field with validation
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required.';
                }
                // Simple regex — Firebase does strict validation server-side.
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(value.trim())) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field with validation
            TextFormField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _handleSignIn(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required.';
                }
                if (value.trim().length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Login button
            PrimaryButton(
              label: 'Login',
              isLoading: _isLoading,
              onPressed: _handleSignIn,
            ),
            const SizedBox(height: 20),

            // Divider between email and social sign-in
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // Google sign-in button
            OutlinedButton.icon(
              onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
              icon: _isGoogleLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.g_mobiledata, size: 24),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 16),

            // Navigate to register
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
