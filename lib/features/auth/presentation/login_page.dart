import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    super.key,
    this.initialSnackBarMessage,
  });

  final String? initialSnackBarMessage;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _showForgotPasswordButton = false;

  @override
  void initState() {
    super.initState();
    final message = widget.initialSnackBarMessage?.trim();
    if (message == null || message.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );

      if (!mounted) return;
      setState(() => _showForgotPasswordButton = false);
      _goToAppRoot();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        if (mounted) {
          setState(() => _showForgotPasswordButton = true);
          _showSnackBar('Email or password is incorrect.');
        }
      } else {
        _showSnackBar(_mapLoginErrorCode(e.code));
      }
    } catch (_) {
      _showSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      _goToAppRoot();
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_mapGoogleErrorCode(e.code));
    } catch (_) {
      _showSnackBar('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _openForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Forgot Password?'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Email is required.';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSending = true);
                          final email = emailCtrl.text.trim();

                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              _showSnackBar('Reset link sent to your email');
                            }
                          } on FirebaseAuthException catch (e) {
                            if (mounted) {
                              _showSnackBar(_mapResetErrorCode(e.code));
                            }
                          } catch (_) {
                            if (mounted) {
                              _showSnackBar(
                                'Unable to send reset email. Please try again.',
                              );
                            }
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => isSending = false);
                            }
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    emailCtrl.dispose();
  }

  String _mapLoginErrorCode(String code) {
    return switch (code) {
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      _ => 'Login failed ($code). Please try again.',
    };
  }

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

  String _mapResetErrorCode(String code) {
    return switch (code) {
      'invalid-email' => 'Invalid email format.',
      'user-not-found' => 'No user found for this email.',
      'too-many-requests' => 'Too many requests. Please try again later.',
      _ => 'Failed to send reset email ($code).',
    };
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToAppRoot() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AuthGate(),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 320),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 12),
                        child: child,
                      ),
                    );
                  },
                  child: CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.26),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: tt.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue organizing your work.',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            hintText: 'name@university.edu',
                            prefixIcon: const Icon(Icons.alternate_email_rounded),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required.';
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Login',
                            onPressed: _handleSignIn,
                            isLoading: _isLoading,
                            icon: Icons.login_rounded,
                          ),
                          if (_showForgotPasswordButton) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openForgotPasswordDialog,
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: cs.outlineVariant),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: tt.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Divider(color: cs.outlineVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                            icon: _isGoogleLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.g_mobiledata_rounded, size: 22),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text("Don't have an account? Register"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
