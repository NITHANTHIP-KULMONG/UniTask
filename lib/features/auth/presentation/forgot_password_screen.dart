import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail?.trim() ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final email = _emailCtrl.text.trim();

    try {
      // Changed: use Firebase built-in reset flow (no custom OTP system).
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.authResetLinkSent),
          ),
        );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_mapResetError(e.code)),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.authResetFailedGeneric),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _mapResetError(String code) {
    final l10n = context.l10n;
    return switch (code) {
      'invalid-email' => l10n.authErrorInvalidEmail,
      'user-not-found' => l10n.authErrorResetUserNotFound,
      'too-many-requests' => l10n.authErrorTooManyRequests,
      _ => l10n.authErrorResetFailed(code),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authForgotPasswordTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CustomCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authResetPasswordTitle,
                      style: tt.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authResetPasswordSubtitle,
                      style: tt.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailCtrl,
                      label: l10n.authEmailLabel,
                      hintText: l10n.authEmailHintAcademic,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return l10n.authEmailRequired;
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return l10n.authEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: l10n.authSendResetEmail,
                      icon: Icons.mark_email_read_outlined,
                      onPressed: _isSending ? null : _submit,
                      isLoading: _isSending,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
