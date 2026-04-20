import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../services/auth_service.dart';

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

  Future<void> _handleSignUp() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signUp(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(_mapErrorCode(e.code));
    } catch (_) {
      _showError(l10n.authUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      'weak-password' => l10n.registerErrorWeakPassword,
      'email-already-in-use' => l10n.registerErrorEmailAlreadyInUse,
      'invalid-email' => l10n.authErrorInvalidEmail,
      'operation-not-allowed' =>
        l10n.registerErrorOperationNotAllowed,
      _ => l10n.registerErrorFailed(code),
    };
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
                          Text(
                            l10n.registerTitle,
                            textAlign: TextAlign.center,
                            style: tt.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.registerSubtitle,
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
                            hintText: l10n.registerPasswordHint,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
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
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmCtrl,
                            label: l10n.registerConfirmPasswordLabel,
                            hintText: l10n.registerConfirmPasswordHint,
                            prefixIcon: const Icon(Icons.lock_person_outlined),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleSignUp(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.registerConfirmPasswordRequired;
                              }
                              if (value.trim() != _passwordCtrl.text.trim()) {
                                return l10n.registerConfirmPasswordMismatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: l10n.registerCreateAccount,
                            onPressed: _handleSignUp,
                            isLoading: _isLoading,
                            icon: Icons.person_add_alt_1_rounded,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.registerAlreadyHaveAccount),
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
