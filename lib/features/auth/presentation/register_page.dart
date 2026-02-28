import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../services/auth_service.dart';

/// Email + password registration page.
///
/// All Firebase logic is delegated to [AuthService].
/// On successful sign-up, [AuthGate] detects the new user via
/// `authStateChanges` and navigates to [HomeShell] automatically.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sign-up handler
  // ---------------------------------------------------------------------------

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signUp(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
      // Pop register route so it's not left on the stack.
      // AuthGate handles the rest.
      if (mounted) Navigator.pop(context);
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

  String _mapErrorCode(String code) {
    return switch (code) {
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'email-already-in-use' =>
        'An account with this email already exists.',
      'invalid-email' => 'The email address is not valid.',
      'operation-not-allowed' =>
        'Email/password sign-up is disabled in the Firebase Console.',
      _ => 'Registration failed ($code). Please try again.',
    };
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),

            // Email
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Password is required.';
                }
                if (v.trim().length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password
            TextFormField(
              controller: _confirmCtrl,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignUp(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please confirm your password.';
                }
                if (v.trim() != _passwordCtrl.text.trim()) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Register button
            PrimaryButton(
              label: 'Register',
              isLoading: _isLoading,
              onPressed: _handleSignUp,
            ),
            const SizedBox(height: 16),

            // Back to login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
