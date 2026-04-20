import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';
import 'forgot_password_screen.dart';
import 'register_page.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.initialSnackBarMessage,
  });

  final String? initialSnackBarMessage;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

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

  Future<void> _handleGoogleSignIn() async {
    final l10n = context.l10n;
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) {
        _goToAppRoot();
      }
    } on FirebaseAuthException catch (e) {
      _showError(_mapGoogleErrorCode(e.code));
    } catch (_) {
      _showError(l10n.authGoogleSignInFailedGeneric);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
      if (mounted) {
        _goToAppRoot();
      }
    } on FirebaseAuthException catch (e) {
      // Changed: when login credentials are invalid, show forgot-password action.
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        _showInvalidCredentialSnackBar();
      } else {
        _showError(_mapErrorCode(e.code));
      }
    } catch (_) {
      _showError(l10n.authUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Changed: shows error and a "Forgot Password?" button only when login fails.
  void _showInvalidCredentialSnackBar() {
    if (!mounted) return;
    final l10n = context.l10n;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.authInvalidCredentials),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.authForgotPassword,
            onPressed: _openForgotPassword,
          ),
        ),
      );
  }

  // Changed: navigates to the dedicated Firebase reset-password screen.
  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          initialEmail: _emailCtrl.text.trim(),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapErrorCode(String code) {
    final l10n = context.l10n;
    return switch (code) {
      'invalid-email' => l10n.authErrorInvalidEmail,
      'user-disabled' => l10n.authErrorUserDisabled,
      'invalid-credential' =>
        l10n.authInvalidCredentials,
      'too-many-requests' =>
        l10n.authErrorTooManyRequests,
      _ => l10n.authErrorLoginFailed(code),
    };
  }

  String _mapGoogleErrorCode(String code) {
    final l10n = context.l10n;
    return switch (code) {
      'popup-blocked' =>
        l10n.authErrorGooglePopupBlocked,
      'popup-closed-by-user' => l10n.authErrorGoogleCancelled,
      'cancelled-popup-request' => l10n.authErrorGoogleCancelled,
      'account-exists-with-different-credential' =>
        l10n.authErrorGoogleAccountExists,
      'user-disabled' => l10n.authErrorUserDisabled,
      _ => l10n.authErrorGoogleFailed(code),
    };
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
    final l10n = context.l10n;

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
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.26),
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
                            l10n.authWelcomeBack,
                            textAlign: TextAlign.center,
                            style: tt.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.authSignInSubtitle,
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _emailCtrl,
                            label: l10n.authEmailLabel,
                            hintText: l10n.authEmailHintAcademic,
                            prefixIcon:
                                const Icon(Icons.alternate_email_rounded),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.authEmailRequired;
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())) {
                                return l10n.authEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordCtrl,
                            label: l10n.authPasswordLabel,
                            hintText: l10n.authPasswordHint,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _handleSignIn(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.authPasswordRequired;
                              }
                              if (value.trim().length < 6) {
                                return l10n.authPasswordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: l10n.authLogin,
                            onPressed: _handleSignIn,
                            isLoading: _isLoading,
                            icon: Icons.login_rounded,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: cs.outlineVariant),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  l10n.authOr,
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
                            onPressed:
                                _isGoogleLoading ? null : _handleGoogleSignIn,
                            icon: _isGoogleLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.g_mobiledata_rounded,
                                    size: 22),
                            label: Text(l10n.authContinueWithGoogle),
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
                            child: Text(l10n.authNoAccountRegister),
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
